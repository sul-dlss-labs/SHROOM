# frozen_string_literal: true

# WorkFile class to capture ActiveStorage file uploads.
class WorkFile < ApplicationRecord
  belongs_to :work, optional: true

  has_one_attached :file
  before_destroy { file.purge_later }

  delegate :blob, to: :file
  delegate :checksum, :content_type, :byte_size, to: :blob

  def filename
    blob.filename.to_s
  end

  def path
    @path ||= ActiveStorage::Blob.service.path_for(blob.key)
  end
end
