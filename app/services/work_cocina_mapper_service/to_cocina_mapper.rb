# frozen_string_literal: true

class WorkCocinaMapperService
  # Map from WorkForm to Cocina model
  class ToCocinaMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    # @param [String,nil] druid
    # @param [Integer] version
    # @param [source_id] source_id
    def initialize(work_form:, druid: nil, version: nil, source_id: nil)
      @work_form = work_form
      @druid = druid
      @version = version || 1
      @source_id = source_id || 'shroom:object-0'
    end

    def call
      if druid
        Cocina::Models.build(params)
      else
        Cocina::Models.build_request(params)
      end
    end

    private

    attr_reader :work_form, :version, :druid, :source_id

    def params
      {
        type: Cocina::Models::ObjectType.object,
        label: work_form.title,
        description: WorkCocinaMapperService::ToCocina::DescriptionMapper.call(work_form:, druid:),
        version:,
        access: { view: 'world', download: 'world' },
        identification: { sourceId: source_id },
        administrative: { hasAdminPolicy: Settings.apo },
        externalIdentifier: druid,
        structural: structural_params
      }.compact
    end

    def structural_params
      {
        contains: []
      }.tap do |params|
        params[:isMemberOf] = [work_form.collection_druid] if work_form.collection_druid.present?
      end
    end
  end
end
