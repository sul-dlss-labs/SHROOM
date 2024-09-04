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
  validates :authors, presence: { message: 'requires at least one author' }

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

  attribute :keywords, array: true, default: -> { [] }
  before_validation do
    keywords.compact_blank!
  end

  def keywords_attributes=(attributes)
    self.keywords = attributes.map { |_, keyword| KeywordForm.new(keyword) }
  end

  # Published articles have a single related resource.
  attribute :related_resource_citation, :string
  validates :related_resource_citation, presence: true, if: :published?

  attribute :related_resource_doi, :string
  validates :related_resource_doi, format: { with: DoiSupport::REGEX }, allow_blank: true, if: :published?

  attribute :published, :boolean, default: false

  attribute :collection_druid, :string

  def published?
    published || related_resource_citation.present?
  end
end
