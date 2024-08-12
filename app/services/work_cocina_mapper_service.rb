# Maps between Cocina model and local model.
class WorkCocinaMapperService
  class Error < StandardError; end
  # Cocina object contains a field that cannot be mapped to a Work.
  class UnmappableError < Error; end

  def self.to_cocina(work:)
    new.to_cocina(work: work)
  end

  def self.to_work(cocina_object:)
    new.to_work(cocina_object: cocina_object)
  end

  # param [Work] work
  # return [Cocina::Models::DRO,Cocina::Models::RequestDRO]
  def to_cocina(work:)
    ToCocinaMapper.call(work: work)
  end

  # param [Cocina::Models::DRO] cocina_object
  # return [Work]
  # raises [UnmappableError]
  def to_work(cocina_object:)
    work = ToWorkMapper.call(cocina_object: cocina_object)
    raise UnmappableError unless roundtrippable?(mapped_work: work, original_cocina_object: cocina_object)

    work
  end

  private

  def roundtrippable?(mapped_work:, original_cocina_object:)
    roundtripped_cocina_object = to_cocina(work: mapped_work)
    roundtripped_cocina_object == original_cocina_object
  end
end
