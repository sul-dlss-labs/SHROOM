class TeiCocinaMapperService
  def self.call(...)
    new(...).call
  end

  # @param [Nokogiri::XML::Document] tei_ng_xml
  def initialize(tei_ng_xml:)
    @tei_doc ||= TeiDocument.new(ng_xml: tei_ng_xml)
  end

  # @return [Cocina::Models::RequestDRO]
  def call
    Cocina::Models.build_request(params)
  end

  private

  attr_reader :tei_doc

  def params
    {
        type: Cocina::Models::ObjectType.object,
        label: tei_doc.title,
        description: description_params,
        version: 1,
        identification: { sourceId: "shroom:object-1" },
        administrative: { hasAdminPolicy: Settings.apo }
    }
  end


  def description_params
    {
      title: CocinaDescriptionSupport.title(title: tei_doc.title),
      contributor: tei_doc.authors.map { |author_attrs| CocinaDescriptionSupport.person_contributor(**author_attrs) }
     }
  end

  class TeiDocument
    def initialize(ng_xml:)
      @ng_xml = ng_xml
    end

    def title
      @title ||= ng_xml.at_xpath("//tei:titleStmt/tei:title", namespaces)&.text
    end

    def authors
      pers_name_nodes = ng_xml.xpath("//tei:author/tei:persName", namespaces)
      pers_name_nodes.map do |pers_name_node|
        {
          forename: pers_name_node.at_xpath("tei:forename", namespaces)&.text,
          surname: pers_name_node.at_xpath("tei:surname", namespaces)&.text
        }
      end
    end

    private

    attr_reader :ng_xml

    def namespaces
      { "tei" => "http://www.tei-c.org/ns/1.0" }
    end
  end
end
