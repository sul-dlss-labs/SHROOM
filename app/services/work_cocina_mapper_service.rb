# frozen_string_literal: true

# Maps between Cocina model and local model.
class WorkCocinaMapperService
  class Error < StandardError; end
  # Cocina object contains a field that cannot be mapped to a Work.
  class UnmappableError < Error; end

  def self.to_cocina(...)
    new.to_cocina(...)
  end

  def self.to_work(...)
    new.to_work(...)
  end

  # @param [WorkForm] work_form
  # @param [String,nil] druid
  # @param [Integer,nil] version
  # @param [String,nil] source_id
  # @return [Cocina::Models::DRO,Cocina::Models::RequestDRO]
  def to_cocina(work_form:, druid: nil, version: nil, source_id: nil)
    ToCocinaMapper.call(work_form:, druid:, version:, source_id:)
  end

  # param [Cocina::Models::DRO] cocina_object
  # param [Boolean] validate_lossless validate that data will not be lost in mapping to work
  # return [WorkForm]
  # raises [UnmappableError]
  def to_work(cocina_object:, validate_lossless: true)
    work_form = ToWorkMapper.call(cocina_object:)
    raise UnmappableError if validate_lossless && !roundtrippable?(mapped_work: work_form,
                                                                   original_cocina_object: cocina_object)

    work_form
  end

  private

  def roundtrippable?(mapped_work:, original_cocina_object:)
    roundtripped_cocina_object = to_cocina(work_form: mapped_work,
                                           druid: original_cocina_object.try(:externalIdentifier),
                                           version: original_cocina_object.version,
                                           source_id: original_cocina_object.identification&.sourceId)
    clean_original_cocina_object = clean_cocina_object(original_cocina_object)
    if roundtripped_cocina_object == clean_original_cocina_object
      true
    else
      Rails.logger.info("Roundtripped Cocina Object: #{roundtripped_cocina_object.to_json}")
      Rails.logger.info("Original Cocina Object: #{clean_original_cocina_object.to_json}")
      Honeybadger.notify('Work not roundtrippable',
                         context: { roundtripped: roundtripped_cocina_object.to_h,
                                    original: clean_original_cocina_object.to_h })
      false
    end
  end

  def clean_cocina_object(cocina_object)
    cocina_object.new(
      label: CocinaSupport.title_for(cocina_object:), # Normalizing label to description title
      structural: { contains: [],
                    isMemberOf: cocina_object.structural.isMemberOf }
    )
  end
end
