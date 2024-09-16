# frozen_string_literal: true

# Model for an affiliation
class AffiliationForm < BaseForm
  attribute :organization, :string
  validates :organization, presence: true

  attribute :ror_id, :string

  delegate :blank?, to: :organization

  attribute :affiliation_options, array: true, default: -> { [] }
  def option
    affiliation_options.first.first if affiliation_options.present?
  end

  attribute :raw_organization, :string
end
