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
        title: cocina_object.description.title.first.value,
        authors: WorkCocinaMapperService::FromCocina::AuthorsMapper.call(cocina_object:),
        abstract: cocina_object.description.note.find { |note| note.type == "abstract" }&.value,
        published_year: published_date&.year,
        published_month: published_date&.month,
        published_day: published_date&.day
      }
    end

    def published_date
      @published_date ||= begin
        event = cocina_object.description.event.find do |event|
          event.type == "deposit" \
          && event.date.first&.encoding&.code == "edtf" \
          && event.date.first&.type == "publication"
        end
        Date.edtf(event&.date&.first&.value)
      end
    end
  end
end
