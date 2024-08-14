class Author < Base
  attribute :first_name, :string
  validates :first_name, presence: true

  attribute :last_name, :string
  validates :last_name, presence: true

  def blank?
    first_name.blank? && last_name.blank?
  end
end
