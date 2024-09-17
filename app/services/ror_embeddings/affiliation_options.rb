# frozen_string_literal: true

module RorEmbeddings
  # Enhance AffiliationForm with ROR suggestions
  class AffiliationOptions
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:)
      @work_form = work_form
    end

    # rubocop:disable Metrics/AbcSize
    def call
      return unless Settings.features_enabled.ror

      work_form.authors.each do |author|
        Parallel.each(author.affiliations, in_threads: 6) do |affiliation|
          organization = affiliation.raw_organization || affiliation.organization
          Rails.logger.info("Searching for #{organization}")
          affiliation.affiliation_options = Rails.cache.fetch("affiliation-#{organization}",
                                                              expires_in: 12.hours) do
            rors = RorEmbeddings::Search.call_split(query: organization)
            rors.map { |ror| [ror.ror_id, ror.label, ror.location] }
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :work_form
  end
end
