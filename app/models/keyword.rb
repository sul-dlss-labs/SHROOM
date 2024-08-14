# frozen_string_literal: true

# Model for a keyword
class Keyword < Base
  attribute :value, :string
  validates :value, presence: true

  delegate :blank?, to: :value
end
