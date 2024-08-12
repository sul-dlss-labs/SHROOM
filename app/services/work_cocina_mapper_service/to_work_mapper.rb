class WorkCocinaMapperService
  class ToWorkMapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def call
      Work.new(params)
    end

    private

    attr_reader :cocina_object

    def params
      {
        title: cocina_object.description.title.first.value
      }
    end
  end
end
