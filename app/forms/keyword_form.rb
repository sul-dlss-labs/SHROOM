# frozen_string_literal: true

# Model for a keyword
class KeywordForm < BaseForm
  attribute :value, :string
  validates :value, presence: true

  delegate :blank?, to: :value
end
