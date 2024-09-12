# frozen_string_literal: true

module RorEmbeddings
  # Load ROR data into the database
  class Loader
    def self.call(...)
      new(...).call
    end

    def initialize(json_filepath: 'ror-data/v1.51-2024-08-21-ror-data_schema_v2.json', limit: nil, resume: false,
                   group_size: 5)
      @json_filepath = json_filepath
      @limit = limit
      @resume = resume
      @group_size = group_size
    end

    # rubocop:disable Metrics/AbcSize
    def call
      Ror.delete_all unless resume
      index = 0 + (Ror.all.length / group_size)
      ror_data.in_groups_of(group_size, false) do |ror_data_group|
        Rails.logger.info("Inserting #{index * group_size}")
        input_data = embeddings_input_data_for(ror_data: ror_data_group)
        ror_attrs = ror_attrs_for(ror_data: ror_data_group)
        insert_for(input_data:, ror_attrs:)
        index += 1
      end
      nil
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :limit, :json_filepath, :resume, :group_size

    def model
      @model ||= RorEmbeddings::Model.new
    end

    def ror_data
      @ror_data ||= begin
        data = JSON.parse(File.read(json_filepath))
        data = data.select { |record| record['status'] == 'active' }
        data.shift(Ror.all.length) if resume
        # Limiting to US
        # data = data.select { |record| record['locations'].first['geonames_details']['country_code'] == 'US' }
        limit ? data.take(limit) : data
      end
    end

    def embeddings_input_data_for(ror_data:)
      ror_data.map do |record|
        parts = []
        # Add an extra display name if a parent. This will help with disambiguation.
        parts << display_name_for(record:) if parent?(record)
        parts.concat(record['names'].pluck('value'))
        parts.concat(record['locations'].map do |location|
                       details = location['geonames_details']
                       [details['name'], details['country_name'], details['country_code']].compact
                     end)
        parts.join(' ')
      end
    end

    def ror_attrs_for(ror_data:)
      ror_data.map do |record|
        label = display_name_for(record:)
        record_location = record['locations'].map do |location|
          details = location['geonames_details']
          [details['name'], details['country_code']].compact.join(', ')
        end.join('; ')
        {
          ror_id: record['id'],
          label:,
          location: record_location
        }
      end
    end

    def display_name_for(record:)
      record['names'].find { |name| name['types'].include?('ror_display') }['value']
    end

    def insert_for(input_data:, ror_attrs:)
      embeddings = model.embed(input_data)

      ror_attrs_with_embeddings = ror_attrs.map.with_index do |ror_attr, index|
        ror_attr.merge(embedding: Neighbor::SparseVector.new(embeddings[index]))
      end
      Ror.insert_all!(ror_attrs_with_embeddings)
    end

    def no_dimensions?(embedding)
      embedding.any? { |dimension| dimension != 0.0 }
    end

    def parent?(record)
      # No parent and has at least one child
      record['relationships'].none? { |relationship| relationship['type'] == 'parent' } &&
        record['relationships'].any? { |relationship| relationship['type'] == 'child' }
    end
  end
end
