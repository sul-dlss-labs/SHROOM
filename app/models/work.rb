class Work < Base
  attribute :title, :string
  validates :title, presence: true
end
