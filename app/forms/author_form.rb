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

  def affiliations_attributes=(attributes)
    self.affiliations = attributes.map { |_, affiliation| AffiliationForm.new(affiliation) }
  end

  def attributes=(attrs)
    if attrs['affiliations']
      self.affiliations = attrs.delete('affiliations').map do |affiliation_attrs|
        AffiliationForm.new(affiliation_attrs)
      end
    end
    super
  end

  def blank?
    first_name.blank? && last_name.blank?
  end
end
