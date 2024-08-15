# frozen_string_literal: true

# Encapsulates a nested form, including adding and removing nested models.
class NestedFormComponent < ViewComponent::Base
  def initialize(form:, model_class:, field:, form_component:)
    @form = form
    @model_class = model_class
    @field = field.to_sym
    @form_component = form_component
    super()
  end

  attr_reader :form, :model_class, :field, :form_component

  def add_label
    "Add #{model_class.model_name.singular}"
  end

  def delete_label
    "Delete #{model_class.model_name.singular}"
  end

  def header_label
    model_class.model_name.plural.titleize
  end
end
