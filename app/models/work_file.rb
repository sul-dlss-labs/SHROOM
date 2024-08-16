# frozen_string_literal: true

# WorkFile class to capture ActiveStorage file uploads.
class WorkFile < ApplicationRecord
  belongs_to :work, optional: true

  has_one_attached :file
  before_destroy { file.purge_later }

  delegate :blob, to: :file

  def path
    ActiveStorage::Blob.service.path_for(blob.key)
  end
end
