class Work < Base
  attribute :title, :string
  validates :title, presence: true

  attribute :authors, array: true, default: []

  def authors_attributes=(attributes)
    self.authors = attributes.map { |_, author| Author.new(author) }
  end
end
