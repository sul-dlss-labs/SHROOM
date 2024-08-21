# frozen_string_literal: true

# Extracts metadata using the Grobid web service and maps to Cocina model.
class GrobidService
  class Error < StandardError; end

  def self.from_file(...)
    new.from_file(...)
  end

  def self.from_doi(...)
    new.from_doi(...)
  end

  # @param path [String] the path to the PDF file
  # @return [Work] a Work model with metadata extracted from the PDF
  # @raise [Error] if there is an error extracting metadata from the PDF
  def from_file(path:)
    @tei = fetch_tei_from_file(path:)
    tei_to_work(tei:)
  end

  # @param doi [String] doi of the work
  # @return [Work] a Work model with metadata extracted from the PDF
  # @raise [Error] if there is an error extracting metadata from the PDF
  def from_doi(doi:)
    tei_fragment = fetch_tei_from_doi(doi:)
    @tei = "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">#{tei_fragment}</TEI>"
    tei_to_work(tei:)
  end

  attr_reader :tei

  private

  def fetch_tei_from_file(path:)
    conn = Faraday.new do |c|
      c.request :multipart
      c.response :raise_error
    end
    payload = { input: Faraday::Multipart::FilePart.new(path, 'application/pdf'), consolidateHeader: 1 }
    headers = { 'Accept' => 'application/xml' }
    response = conn.post("#{Settings.grobid.host}/api/processHeaderDocument", payload, headers)
    response.body
  rescue Faraday::Error => e
    raise Error, "Error extracting metadata from PDF: #{e.message}"
  end

  def fetch_tei_from_doi(doi:)
    conn = Faraday.new do |c|
      c.response :raise_error
    end
    payload = { citations: doi, consolidateCitations: 1 }
    headers = { 'Accept' => 'application/xml', 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = conn.post("#{Settings.grobid.host}/api/processCitation", URI.encode_www_form(payload), headers)
    response.body
  rescue Faraday::Error => e
    raise Error, "Error getting metadata by DOI: #{e.message}"
  end

  def conn
    Faraday.new do |conn|
      conn.request :multipart
      conn.response :raise_error
    end
  end

  def tei_to_work(tei:)
    Rails.logger.info("TEI: #{tei}")
    cocina_object = TeiCocinaMapperService.call(tei_ng_xml: Nokogiri::XML(tei))
    Rails.logger.info("Cocina object: #{CocinaSupport.pretty(cocina_object:)}")
    WorkCocinaMapperService.to_work(cocina_object:, validate_lossless: false)
  end
end
