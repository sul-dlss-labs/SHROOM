# frozen_string_literal: true

# Model for a scholarly work
class WorkForm < BaseForm
  attribute :title, :string
  validates :title, presence: true

  attribute :authors, array: true, default: -> { [] }
  before_validation do
    authors.compact_blank!
  end
  validate :authors_are_valid

  def authors_attributes=(attributes)
    self.authors = attributes.map { |_, author| AuthorForm.new(author) }
  end

  def authors_are_valid
    authors.each do |author|
      next if author.valid?

      author.errors.each do |error|
        errors.add("authors.#{authors.index(author)}.#{error.attribute}", error.message)
      end
    end
  end

  attribute :abstract, :string

  # For a preprint, the published date is the date the preprint was published not the actual publication date.
  attribute :published_year, :integer
  validates :published_year, numericality: { only_integer: true, in: 1900..Date.current.year }, allow_nil: true

  attribute :published_month, :integer
  validates :published_month, numericality: { only_integer: true, in: 1..12 }, allow_nil: true
  validate :published_month_is_valid

  def published_month_is_valid
    errors.add(:published_month, 'requires a year') if published_year.blank? && published_month.present?
  end

  attribute :published_day, :integer
  validates :published_day, numericality: { only_integer: true, in: 1..31 }, allow_nil: true
  validate :published_day_is_valid

  def published_day_is_valid
    return unless (published_year.blank? || published_month.blank?) && published_day.present?

    errors.add(:published_day,
               'requires a year and month')
  end

  # Preprints don't have publishers
  attribute :publisher, :string

  attribute :doi, :string
  validates :doi, format: { with: DoiSupport::REGEX }, allow_blank: true, unless: :preprint?

  attribute :keywords, array: true, default: -> { [] }
  before_validation do
    keywords.compact_blank!
  end

  def keywords_attributes=(attributes)
    self.keywords = attributes.map { |_, keyword| KeywordForm.new(keyword) }
  end

  # Preprints have a single related resource.
  attribute :related_resource_citation, :string
  validates :related_resource_citation, presence: true, if: :preprint?

  attribute :related_resource_doi, :string
  validates :related_resource_doi, format: { with: DoiSupport::REGEX }, allow_blank: true, if: :preprint?

  attribute :preprint, :boolean, default: false

  attribute :collection_druid, :string

  def preprint?
    preprint || related_resource_citation.present?
  end
end
