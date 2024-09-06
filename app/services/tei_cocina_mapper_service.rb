# frozen_string_literal: true

# Map from TEI XML to Cocina model
class TeiCocinaMapperService
  TEI_NAMESPACES = { 'tei' => 'http://www.tei-c.org/ns/1.0' }.freeze

  def self.call(...)
    new(...).call
  end

  # @param [Nokogiri::XML::Document] tei_ng_xml
  # @param [String,nil] related_resource_citation citation for the article this is a published of
  def initialize(tei_ng_xml:, related_resource_citation: nil)
    @tei_doc = TeiDocument.new(ng_xml: tei_ng_xml)
    @related_resource_citation = related_resource_citation
  end

  # @return [Cocina::Models::RequestDRO]
  def call
    Cocina::Models.build_request(params)
  end

  private

  attr_reader :tei_doc, :related_resource_citation

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
      subject: subject_params,
      relatedResource: related_resource_params
    }.compact
  end

  def note_params
    return if tei_doc.abstract.blank?

    [CocinaDescriptionSupport.note(type: 'abstract', value: tei_doc.abstract)]
  end

  def subject_params
    return if tei_doc.keywords.blank?

    CocinaDescriptionSupport.subjects(values: tei_doc.keywords)
  end

  def related_resource_params
    return unless published?

    [
      {
        note: [CocinaDescriptionSupport.related_resource_note(citation: related_resource_citation)]
      }.tap do |params|
        params[:identifier] = [CocinaDescriptionSupport.doi_identifier(doi: tei_doc.doi)] if tei_doc.doi.present?
      end
    ]
  end

  def published?
    related_resource_citation.present?
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

    def doi
      @doi ||= ng_xml.at_xpath('//tei:idno[@type="DOI"]', TEI_NAMESPACES)&.text
    end

    attr_reader :ng_xml

    private

    def name_attrs_for(author_node)
      pers_name_node = author_node.at_xpath('tei:persName', TEI_NAMESPACES)
      return {} unless pers_name_node

      {
        forename: join_nodes(pers_name_node.xpath('tei:forename', TEI_NAMESPACES)),
        surname: join_nodes(pers_name_node.xpath('tei:surname', TEI_NAMESPACES))
      }.compact
    end

    def join_nodes(nodes)
      nodes.map(&:text).join(' ')
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

      { organization: }
    end
  end
end
