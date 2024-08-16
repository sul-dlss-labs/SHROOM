# frozen_string_literal: true

# WorkFile class to capture ActiveStorage file uploads.
class WorkFile < ApplicationRecord
  has_one_attached :file
  before_destroy { file.purge_later }
end
