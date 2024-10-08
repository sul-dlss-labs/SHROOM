# frozen_string_literal: true

class MetadataExtractionService
  # Extracts metadata using the Grobid web service and maps to Cocina model.
  class Grobid
    def self.from_file(path:, logger: Rails.logger, published: false)
      new(logger:).from_file(path:, published:)
    end

    # @param [Logger] logger
    def initialize(logger: Rails.logger)
      @logger = logger
    end

    # @param [String] path the path to the PDF file
    # @param [Boolean] published whether the work is a published article
    # @return [WorkForm] a Work model with metadata extracted from the PDF
    # @raise [Error] if there is an error extracting metadata from the PDF
    def from_file(path:, published: false)
      @tei = fetch_tei_from_file(path:)
      @bibtex = fetch_tei_from_file(path:, tei: false) if published
      tei_to_work(tei:, bibtex:)
    end

    def info_fields
      %i[tei bibtex]
    end

    attr_reader :tei, :bibtex, :logger

    private

    def fetch_tei_from_file(path:, tei: true)
      conn = Faraday.new do |c|
        c.request :multipart
        c.response :raise_error
      end
      payload = { input: Faraday::Multipart::FilePart.new(path, 'application/pdf'),
                  consolidateHeader: consolidate? ? 1 : 0 }
      headers = { 'Accept' => tei ? 'application/xml' : 'application/x-bibtex' }
      response = conn.post("#{Settings.grobid.host}/api/processHeaderDocument", payload, headers)
      response.body
    rescue Faraday::Error => e
      raise MetadataExtractionService::Error, "Error extracting metadata from PDF: #{e.message}"
    end

    def fetch_tei_from_citation(citation:, tei: true)
      conn = Faraday.new do |c|
        c.response :raise_error
      end
      payload = { citations: citation, consolidateCitations: 1 }
      headers = {
        'Accept' => tei ? 'application/xml' : 'application/x-bibtex',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      response = conn.post("#{Settings.grobid.host}/api/processCitation", URI.encode_www_form(payload), headers)
      response.body
    rescue Faraday::Error => e
      raise MetadataExtractionService::Error, "Error getting metadata by citation: #{e.message}"
    end

    def conn
      Faraday.new do |conn|
        conn.request :multipart
        conn.response :raise_error
      end
    end

    def tei_to_work(tei:, bibtex:)
      logger.info("TEI: #{tei}")
      logger.info("Bibtex: #{bibtex}") if bibtex
      cocina_object = TeiCocinaMapperService.call(tei_ng_xml: Nokogiri::XML(tei),
                                                  related_resource_citation: citation_for(bibtex:))
      logger.info("Cocina object: #{CocinaSupport.pretty(cocina_object:)}")
      WorkCocinaMapperService.to_work(cocina_object:, validate_lossless: false)
    end

    def citation_for(bibtex:)
      return nil unless bibtex

      cp = CiteProc::Processor.new style: 'apa', format: 'text'
      cp.import BibTeX.parse(bibtex).to_citeproc
      id = cp.items.keys.first
      cp.render(:bibliography, id:).first
    end

    def citation_processor
      CiteProc::Ruby::Renderer.new(format: 'html')
      @citation_processor ||= CiteProc::Processor.new style: 'apa', format: 'text'
    end

    def consolidate?
      Settings.grobid.consolidate
    end
  end
end
