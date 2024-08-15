# frozen_string_literal: true

# Service for purging the work_file and storage directory.
class PurgeWorkFileService
  def self.purge(...)
    new.purge(...)
  end

  # @param work_file [WorkFile] the work_file to be cleaned up
  def purge(work_file:)
    file_path = storage_path(work_file:) # Capture the parent path before purging the blob.
    work_file.file.purge
    clean_storage_path(file_path)
    work_file.destroy
  end

  private

  def storage_path(work_file:)
    Pathname.new(ActiveStorage::Blob.service.path_for(work_file.file.blob.key)).parent
  end

  # Clean up any empty directories in the ActiveStorage object tree.
  def clean_storage_path(path)
    return unless path.exist? && path.empty?

    FileUtils.rm_rf(path)
    clean_storage_path(path.parent)
  end
end
