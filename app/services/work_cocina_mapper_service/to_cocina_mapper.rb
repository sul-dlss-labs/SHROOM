# frozen_string_literal: true

class WorkCocinaMapperService
  # Map from Work to Cocina model
  class ToCocinaMapper
    def self.call(...)
      new(...).call
    end

    def initialize(work:)
      @work = work
    end

    def call
      Cocina::Models.build_request(params)
    end

    private

    attr_reader :work

    def params
      {
        type: Cocina::Models::ObjectType.object,
        label: work.title,
        description: WorkCocinaMapperService::ToCocina::DescriptionMapper.call(work:),
        version: 1,
        identification: { sourceId: 'shroom:object-1' },
        administrative: { hasAdminPolicy: Settings.apo }
      }
    end
  end
end
