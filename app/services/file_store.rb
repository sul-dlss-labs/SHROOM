# frozen_string_literal: true

# Service for storing files in the file system.
class FileStore
  def self.store(...)
    new.store(...)
  end

  def self.lookup(...)
    new.lookup(...)
  end

  def self.delete(...)
    new.delete(...)
  end

  # @param path [String] the path to the file to be stored
  # @return [String] key for the stored file
  def store(path:)
    FileUtils.mkdir_p(store_path) unless File.directory?(store_path)

    key = SecureRandom.uuid
    FileUtils.cp(path, path_for(key))
    key
  end

  # @param key [String] the key of the file to be retrieved
  # @return [String] the path to the stored file
  def lookup(key:)
    path_for(key)
  end

  # @param key [String] the key of the file to be deleted
  def delete(key:)
    FileUtils.rm_f(path_for(key))
  end

  private

  def store_path
    Settings.file_store.path
  end

  def path_for(key)
    File.join(store_path, key)
  end
end
