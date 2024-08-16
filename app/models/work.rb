# Model for a work
class Work < ApplicationRecord
  has_many :work_files, dependent: :destroy
end
