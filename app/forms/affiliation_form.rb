# frozen_string_literal: true

# Model for an affiliation
class AffiliationForm < BaseForm
  attribute :organization, :string
  validates :organization, presence: true

  delegate :blank?, to: :organization
end
