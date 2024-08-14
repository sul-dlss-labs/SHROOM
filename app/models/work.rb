class Work < Base
  attribute :title, :string
  validates :title, presence: true

  attribute :authors, array: true, default: []
  before_validation :compact_authors
  validate :authors_are_valid

  def authors_attributes=(attributes)
    self.authors = attributes.map { |_, author| Author.new(author) }
  end

  def compact_authors
    authors.delete_if(&:blank?)
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

  attribute :published_year, :integer
  validates :published_year, numericality: { only_integer: true, in: 1900..Date.current.year  }, allow_nil: true

  attribute :published_month, :integer
  validates :published_month, numericality: { only_integer: true, in: 1..12 }, allow_nil: true
  validate :published_month_is_valid

  def published_month_is_valid
    errors.add(:published_month, "requires a year") if published_year.blank? && published_month.present?
  end

  attribute :published_day, :integer
  validates :published_day, numericality: { only_integer: true, in: 1..31 }, allow_nil: true
  validate :published_day_is_valid

  def published_day_is_valid
    errors.add(:published_day, "requires a year and month") if (published_year.blank? || published_month.blank?) && published_day.present?
  end
end
