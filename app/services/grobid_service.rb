# Extracts metadata from a supplied PDF using the Grobid web service and maps to Cocina model.
class GrobidService
  class Error < StandardError; end

  def self.call(...)
    new(...).call
  end

  # @param path [String] the path to the PDF file
  def initialize(path:)
    @path = path
  end

  # @return [Work] a Work model with metadata extracted from the PDF
  # @raise [Error] if there is an error extracting metadata from the PDF
  def call
    tei = fetch_tei
    Rails.logger.info("TEI: #{tei}")
    cocina_object = TeiCocinaMapperService.call(tei_ng_xml: Nokogiri::XML(tei))
    Rails.logger.info("Cocina object: #{CocinaSupport.pretty(cocina_object:)}")
    WorkCocinaMapperService.to_work(cocina_object: cocina_object, validate_lossless: false)
  end

  private

  attr_reader :path

  def fetch_tei
    conn = Faraday.new do |conn|
      conn.request :multipart
      conn.response :raise_error
    end
    payload = { input: Faraday::Multipart::FilePart.new(path, "application/pdf"), consolidateHeader: 1 }
    headers = { "Accept" => "application/xml" }
    response = conn.post("#{Settings.grobid.host}/api/processHeaderDocument", payload, headers)
    response.body
  rescue Faraday::Error => e
    raise Error, "Error extracting metadata from PDF: #{e.message}"
  end
end
