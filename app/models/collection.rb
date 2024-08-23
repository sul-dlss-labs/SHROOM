# frozen_string_literal: true

# Model for a collection
class Collection < ApplicationRecord
  has_many :works, dependent: :nullify
end
