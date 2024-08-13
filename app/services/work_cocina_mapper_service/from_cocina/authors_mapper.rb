class WorkCocinaMapperService
  module FromCocina
    class AuthorsMapper
      def self.call(...)
        new(...).call
      end

      # @param [Cocina::Models::DRO,Cocina::Models::RequestDRO] cocina_object
      def initialize(cocina_object:)
        @cocina_object = cocina_object
      end

      # @return [Array<Author>]
      def call
        cocina_object.description.contributor.map do |contributor|
          next unless contributor.type == "person"
          Author.new(
            first_name: contributor.name.first.structuredValue.find { |name| name.type == "forename" }.value,
            last_name: contributor.name.first.structuredValue.find { |name| name.type == "surname" }.value
          )
        end.compact
      end

      private

      attr_reader :cocina_object
    end
  end
end
