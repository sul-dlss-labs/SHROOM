# frozen_string_literal: true

# Model for an affiliation
class AffiliationForm < BaseForm
  attribute :organization, :string
  validates :first_name, presence: true

  attribute :department, :string

  def blank?
    organization.blank? && department.blank?
  end
end
