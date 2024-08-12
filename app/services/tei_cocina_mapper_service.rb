class TeiCocinaMapperService
  def self.call(...)
    new(...).call
  end

  # @param [Nokogiri::XML::Document] tei_ng_xml
  def initialize(tei_ng_xml:)
    @tei_ng_xml = tei_ng_xml
  end

  # @return [Cocina::Models::RequestDRO]
  def call
    Cocina::Models.build_request(params)
  end

  private

  attr_reader :tei_ng_xml

  def params
    {
        type: Cocina::Models::ObjectType.object,
        label: title,
        description: { title: [ { value: title } ] },
        version: 1,
        identification: { sourceId: "shroom:object-1" },
        administrative: { hasAdminPolicy: Settings.apo }
    }
  end

  def title
    @title ||= tei_ng_xml.at_xpath("//tei:titleStmt/tei:title", namespaces)&.text
  end

  def namespaces
    { "tei" => "http://www.tei-c.org/ns/1.0" }
  end
end
