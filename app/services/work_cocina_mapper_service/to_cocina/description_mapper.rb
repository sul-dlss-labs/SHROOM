class WorkCocinaMapperService
  module ToCocina
    # Maps from a Work to a Cocina Description.
    class DescriptionMapper
      def self.call(...)
        new(...).call
      end

      # @param [Work] work
      def initialize(work:)
        @work = work
      end

      # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
      def call
        Cocina::Models::RequestDescription.new(params)
      end

      private

      attr_reader :work

      def params
        {
          title: CocinaDescriptionSupport.title(title: work.title),
          contributor: contributors_params.presence
        }.compact
      end

      def contributors_params
        work.authors.map do |contributor|
          CocinaDescriptionSupport.person_contributor(forename: contributor.first_name, surname: contributor.last_name)
        end
      end
    end
  end
end
