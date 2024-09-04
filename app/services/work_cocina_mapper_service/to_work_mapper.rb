# frozen_string_literal: true

class WorkCocinaMapperService
  # Maps from Cocina model to WorkForm
  class ToWorkMapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def call
      WorkForm.new(params)
    end

    private

    attr_reader :cocina_object

    def params
      {
        title: CocinaSupport.title_for(cocina_object:),
        authors: WorkCocinaMapperService::ToWork::AuthorsMapper.call(cocina_object:),
        abstract: cocina_object.description.note.find { |note| note.type == 'abstract' }&.value,
        keywords:,
        related_resource_citation:,
        related_resource_doi:,
        collection_druid: CocinaSupport.collection_druid_for(cocina_object:)
      }
    end

    def keywords
      cocina_object.description.subject
                   .select { |subject| subject.type == 'topic' }
                   .map { |subject| KeywordForm.new(value: subject.value) }
    end

    def related_resource_citation
      note = related_resource&.note&.find { |n| n.type == 'preferred citation' }
      return unless note

      note.value
    end

    def related_resource_doi
      doi_for(related_resource)
    end

    def doi_for(resource)
      identifier = resource&.identifier&.find { |id| id.type == 'DOI' }
      return unless identifier

      identifier.value
    end

    def related_resource
      @related_resource ||= cocina_object.description.relatedResource.first
    end
  end
end
