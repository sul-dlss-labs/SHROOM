# frozen_string_literal: true

# Factory class to instantiate the metadata extraction service based on the configuration
class MetadataExtractionService
  def self.new(logger: Rails.logger)
    "MetadataExtractionService::#{Settings.metadata_extraction_service}".constantize.new(logger:)
  end

  class Error < StandardError; end
end
