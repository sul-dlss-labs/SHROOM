# frozen_string_literal: true

module Sdr
  # Service to get version status from SDR.
  class VersionService
    def self.openable?(druid:)
      Dor::Services::Client.object(druid).version.status.openable?
    end
  end
end
