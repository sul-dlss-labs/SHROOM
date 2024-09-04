# frozen_string_literal: true

module Works
  # Provides a fallback to provide a DOI or citation.
  class FallbackFormComponent < ViewComponent::Base
    def initialize(work_form:, work_file_id:, published:)
      @work_form = work_form
      @work_file_id = work_file_id
      @published = published
      super()
    end

    attr_reader :work_form, :work_file_id, :published

    def render?
      work_form.title.blank? && work_file_id
    end
  end
end
