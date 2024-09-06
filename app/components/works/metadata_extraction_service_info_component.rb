# frozen_string_literal: true

module Works
  # Renders the raw metadata extraction service information
  class MetadataExtractionServiceInfoComponent < ViewComponent::Base
    def initialize(service:)
      @service = service
      super()
    end

    attr_reader :service

    delegate :info_fields, to: :service

    def render?
      service.present?
    end

    def body_for(field)
      body = service.send(field)
      return body unless body.is_a?(Hash) || body.is_a?(Array)

      JSON.pretty_generate(body)
    end
  end
end
