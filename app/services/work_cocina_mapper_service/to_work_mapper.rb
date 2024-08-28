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

    # rubocop:disable Metrics/AbcSize
    def params
      {
        title: cocina_object.description.title.first.value,
        authors: WorkCocinaMapperService::ToWork::AuthorsMapper.call(cocina_object:),
        abstract: cocina_object.description.note.find { |note| note.type == 'abstract' }&.value,
        published_year: published_date&.year,
        published_month: EdtfSupport.month_for(edtf: published_date),
        published_day: EdtfSupport.day_for(edtf: published_date),
        publisher:,
        keywords:,
        doi:,
        related_resource_citation:,
        related_resource_doi:,
        collection_druid:
      }
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def published_date
      @published_date ||= begin
        published_event = cocina_object.description.event.find do |event|
          event.type == 'deposit' \
          && event.date.first&.encoding&.code == 'edtf' \
          && event.date.first&.type == 'publication'
        end
        EdtfSupport.parse_with_precision(date: published_event&.date&.first&.value)
      end
    end

    def publisher
      publisher_event = cocina_object.description.event.find do |event|
        event.type == 'publication' \
        && event.contributor&.first&.role&.first&.value == 'publisher'
      end
      publisher_event&.contributor&.first&.name&.first&.value
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

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

    def doi
      doi_for(cocina_object.description)
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

    def collection_druid
      cocina_object.structural&.isMemberOf&.first
    end
  end
end
