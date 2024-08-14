# frozen_string_literal: true

# Base class for nested form components.
class BaseNestedFormComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
    super()
  end

  attr_reader :form
end
