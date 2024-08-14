# frozen_string_literal: true

# Map from TEI XML to Cocina model
class TeiCocinaMapperService
  def self.call(...)
    new(...).call
  end

  # @param [Nokogiri::XML::Document] tei_ng_xml
  def initialize(tei_ng_xml:)
    @tei_doc = TeiDocument.new(ng_xml: tei_ng_xml)
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
      identification: { sourceId: 'shroom:object-1' },
      administrative: { hasAdminPolicy: Settings.apo }
    }
  end

  def description_params
    {
      title: CocinaDescriptionSupport.title(title: tei_doc.title),
      contributor: tei_doc.authors.map { |author_attrs| CocinaDescriptionSupport.person_contributor(**author_attrs) },
      note: note_params,
      event: event_params,
      subject: subject_params
    }.compact
  end

  def note_params
    return if tei_doc.abstract.blank?

    [CocinaDescriptionSupport.note(type: 'abstract', value: tei_doc.abstract)]
  end

  def event_params
    [].tap do |params|
      if tei_doc.published_date.present?
        params << CocinaDescriptionSupport.event_date(date_type: 'publication',
                                                      date_value: tei_doc.published_date)
      end
      if tei_doc.publisher.present?
        params << CocinaDescriptionSupport.event_contributor(contributor_name_value: tei_doc.publisher)
      end
    end
  end

  def subject_params
    return if tei_doc.keywords.blank?

    CocinaDescriptionSupport.subjects(values: tei_doc.keywords)
  end

  # Wrapper around a TEI XML document
  class TeiDocument
    def initialize(ng_xml:)
      @ng_xml = ng_xml
    end

    def title
      @title ||= ng_xml.at_xpath('//tei:titleStmt/tei:title', namespaces)&.text
    end

    def authors
      pers_name_nodes = ng_xml.xpath('//tei:author/tei:persName', namespaces)
      pers_name_nodes.map do |pers_name_node|
        {
          forename: pers_name_node.at_xpath('tei:forename', namespaces)&.text,
          surname: pers_name_node.at_xpath('tei:surname', namespaces)&.text
        }
      end
    end

    def abstract
      @abstract ||= ng_xml.at_xpath('//tei:profileDesc/tei:abstract/tei:p', namespaces)&.text
    end

    def published_date
      @published_date ||= ng_xml.at_xpath("//tei:publicationStmt/tei:date[@type='published']/@when", namespaces)&.text
    end

    def publisher
      @publisher ||= ng_xml.at_xpath('//tei:publicationStmt/tei:publisher', namespaces)&.text
    end

    def keywords
      @keywords ||= ng_xml.xpath('//tei:keywords/tei:term', namespaces).map(&:text)
    end

    private

    attr_reader :ng_xml

    def namespaces
      { 'tei' => 'http://www.tei-c.org/ns/1.0' }
    end
  end
end
