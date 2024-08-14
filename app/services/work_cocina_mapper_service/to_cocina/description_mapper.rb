# frozen_string_literal: true

class WorkCocinaMapperService
  module ToCocina
    # Maps from a Work to a Cocina Description.
    class DescriptionMapper
      def self.call(...)
        new(...).call
      end

      # @param [Work] work
      def initialize(work:)
        @work = work
      end

      # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
      def call
        Cocina::Models::RequestDescription.new(params)
      end

      private

      attr_reader :work

      def params
        {
          title: CocinaDescriptionSupport.title(title: work.title),
          contributor: contributors_params.presence,
          note: note_params.presence,
          event: event_params.presence
        }.compact
      end

      def contributors_params
        work.authors.map do |contributor|
          CocinaDescriptionSupport.person_contributor(forename: contributor.first_name, surname: contributor.last_name)
        end
      end

      def note_params
        [].tap do |params|
          params << CocinaDescriptionSupport.note(type: 'abstract', value: work.abstract) if work.abstract.present?
        end
      end

      # rubocop:disable Metrics/AbcSize
      def event_params
        [].tap do |params|
          date_value = EdtfSupport.to_edtf(year: work.published_year, month: work.published_month,
                                           day: work.published_day)
          params << CocinaDescriptionSupport.event_date(date_value:, date_type: 'publication') if date_value.present?
          if work.publisher.present?
            params << CocinaDescriptionSupport.event_contributor(contributor_name_value: work.publisher)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
