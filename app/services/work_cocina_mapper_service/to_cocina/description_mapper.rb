# frozen_string_literal: true

class WorkCocinaMapperService
  module ToCocina
    # Maps from a WorkForm to a Cocina Description.
    class DescriptionMapper
      def self.call(...)
        new(...).call
      end

      # @param [WorkForm] work_form
      # @param [String,nil] druid
      def initialize(work_form:, druid: nil)
        @work_form = work_form
        @druid = druid
      end

      # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
      def call
        if druid
          Cocina::Models::Description.new(params)

        else
          Cocina::Models::RequestDescription.new(params)

        end
      end

      private

      attr_reader :work_form, :druid

      def params
        {
          title: CocinaDescriptionSupport.title(title: work_form.title),
          contributor: contributors_params.presence,
          note: note_params.presence,
          subject: subject_params.presence,
          purl: Sdr::Purl.from_druid(druid:),
          relatedResource: related_resource_params
        }.compact
      end

      def contributors_params
        work_form.authors.map do |contributor|
          CocinaDescriptionSupport.person_contributor(
            forename: contributor.first_name,
            surname: contributor.last_name,
            affiliations: affiliation_params_for(contributor)
          )
        end
      end

      def affiliation_params_for(contributor)
        contributor.affiliations.map do |affiliation|
          { organization: affiliation.organization, ror_id: affiliation.ror_id }.compact
        end
      end

      def note_params
        [].tap do |params|
          if work_form.abstract.present?
            params << CocinaDescriptionSupport.note(type: 'abstract',
                                                    value: work_form.abstract)
          end
        end
      end

      def subject_params
        CocinaDescriptionSupport.subjects(values: work_form.keywords.map(&:value))
      end

      def related_resource_params
        resource_params = {}.tap do |params|
          if work_form.related_resource_citation.present?
            params[:note] =
              [CocinaDescriptionSupport.related_resource_note(citation: work_form.related_resource_citation)]
          end
          if work_form.related_resource_doi.present?
            params[:identifier] = [CocinaDescriptionSupport.doi_identifier(doi: work_form.related_resource_doi)]
          end
        end
        return if resource_params.empty?

        [resource_params]
      end
    end
  end
end
