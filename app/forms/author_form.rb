# frozen_string_literal: true

# Model for an author
class AuthorForm < BaseForm
  attribute :first_name, :string
  validates :first_name, presence: true

  attribute :last_name, :string
  validates :last_name, presence: true

  attribute :affiliations, array: true, default: -> { [] }
  before_validation do
    affiliations.compact_blank!
  end

  attribute :orcid, :string
  validates :orcid, format: { with: OrcidSupport::REGEX }, allow_blank: true

  def affiliations_attributes=(attributes)
    self.affiliations = attributes.map { |_, affiliation| AffiliationForm.new(affiliation) }
  end

  def blank?
    first_name.blank? && last_name.blank?
  end
end
