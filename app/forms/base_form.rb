# frozen_string_literal: true

# Base class for form objects
class BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  def self.model_name
    # Remove the "Form" suffix from the class name.
    model_name = method(:model_name).super_method.call.to_s
    ActiveModel::Name.new(self, nil, model_name.delete_suffix('Form'))
  end
end
