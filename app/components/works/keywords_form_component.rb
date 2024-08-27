# frozen_string_literal: true

module Works
  # Encapsulates nested keyword forms
  class KeywordsFormComponent < ViewComponent::Base
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
