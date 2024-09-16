# frozen_string_literal: true

module Geonames
  # Remove geonames from an affiliation string
  class Clean
    def self.call(...)
      new(...).call
    end

    def self.clean(work_form:)
      work_form.authors.each do |author|
        author.affiliations.each do |affiliation|
          affiliation.raw_organization = affiliation.organization
          affiliation.organization = Geonames::Clean.call(affiliation: affiliation.organization)
        end
      end
      work_form
    end

    def initialize(affiliation:)
      @affiliation = affiliation
    end

    def call
      parts = affiliation.split(/, ?/)
      parts.pop while Geoname.exists?(name: parts.last.downcase)
      parts.join(', ')
    end

    private

    attr_reader :affiliation
  end
end
