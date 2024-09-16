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
    affiliations.uniq! { |affiliation| [affiliation.organization, affiliation.ror_id] }
  end
  validate :affiliations_are_valid

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

  # rubocop:disable Metrics/AbcSize
  def affiliations_are_valid
    affiliations.each do |affiliation|
      affiliation.valid?
      if affiliations.count { |check_affiliation| check_affiliation.organization == affiliation.organization } > 1
        affiliation.errors.add(:organization, 'duplicate affiliation')
      end

      affiliation.errors.each do |error|
        errors.add("affiliations.#{affiliations.index(affiliation)}.#{error.attribute}", error.message)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def blank?
    first_name.blank? && last_name.blank?
  end
end
