# frozen_string_literal: true

module Sdr
  # Service to interact with SDR.
  class Repository
    class Error < StandardError; end
    class NotFoundResponse < Error; end

    # @param [String] druid the druid of the object
    # @return [Cocina::Models::DRO,Cocina::Models::Collection] the returned model
    # @raise [Error] if there is an error retrieving the object
    # @raise [NotFoundResponse] if the object is not found
    def self.find(druid:)
      cocina_object = Dor::Services::Client.object(druid).find
      Cocina::Models.without_metadata(cocina_object)
    end
  end
end
