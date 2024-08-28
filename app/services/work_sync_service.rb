# frozen_string_literal: true

# Updates a Work based on a cocina object
class WorkSyncService
  def self.call(...)
    new(...).call
  end

  # @param [Work] work
  # @param [Cocina::Models::DRO,Cocina::Models::RequestDRO] cocina_object
  def initialize(work:, cocina_object:)
    @work = work
    @cocina_object = cocina_object
  end

  def call
    work.update!(title:, collection:)
  end

  private

  attr_reader :work, :cocina_object

  def title
    CocinaSupport.title_for(cocina_object:)
  end

  def collection_druid
    @collection_druid ||= CocinaSupport.collection_druid_for(cocina_object:)
  end

  def collection
    return unless collection_druid

    collection = Collection.find_by(druid: collection_druid)
    return collection if collection

    collection_cocina_object = Sdr::Repository.find(druid: collection_druid)
    Collection.create!(druid: collection_druid, title: CocinaSupport.title_for(cocina_object: collection_cocina_object))
  end
end
