# frozen_string_literal: true

# Map from TEI XML to Cocina model
class TeiCocinaMapperService
  TEI_NAMESPACES = { 'tei' => 'http://www.tei-c.org/ns/1.0' }.freeze

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
      identification: { sourceId: 'shroom:object-0' },
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
      @title ||= ng_xml.at_xpath('//tei:title', TEI_NAMESPACES)&.text
    end

    def authors
      author_nodes = ng_xml.xpath('//tei:author', TEI_NAMESPACES)
      author_nodes.filter_map do |author_node|
        author_attrs = name_attrs_for(author_node)
        next if author_attrs.blank?

        author_attrs.merge(affiliations_attrs_for(author_node))
      end
    end

    def abstract
      @abstract ||= ng_xml.at_xpath('//tei:abstract/tei:p', TEI_NAMESPACES)&.text
    end

    def published_date
      @published_date ||= ng_xml.at_xpath("//tei:date[@type='published']/@when",
                                          TEI_NAMESPACES)&.text
    end

    def publisher
      @publisher ||= ng_xml.at_xpath('//tei:publisher', TEI_NAMESPACES)&.text
    end

    def keywords
      @keywords ||= ng_xml.xpath('//tei:keywords/tei:term', TEI_NAMESPACES).map(&:text)
    end

    attr_reader :ng_xml

    private

    def name_attrs_for(author_node)
      pers_name_node = author_node.at_xpath('tei:persName', TEI_NAMESPACES)
      return {} unless pers_name_node

      {
        forename: pers_name_node.at_xpath('tei:forename', TEI_NAMESPACES)&.text,
        surname: pers_name_node.at_xpath('tei:surname', TEI_NAMESPACES)&.text
      }.compact
    end

    def affiliations_attrs_for(author_node)
      affiliation_nodes = author_node.xpath('tei:affiliation', TEI_NAMESPACES)
      return {} if affiliation_nodes.blank?

      {
        affiliations: affiliation_nodes.filter_map { |affiliation_node| affiliation_attrs_for(affiliation_node) }
      }
    end

    def affiliation_attrs_for(affiliation_node)
      organization = affiliation_node.at_xpath('tei:orgName[@type="institution"][last()]', TEI_NAMESPACES)&.text
      return if organization.blank?

      {
        department: affiliation_node.at_xpath('tei:orgName[@type="department"]', TEI_NAMESPACES)&.text,
        organization:
      }.compact
    end
  end
end
