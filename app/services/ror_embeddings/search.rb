# frozen_string_literal: true

module RorEmbeddings
  # Search for ROR records using embeddings
  class Search
    def self.call(...)
      new.call(...)
    end

    def self.call_split(...)
      new.call_split(...)
    end

    def initialize
      # Instantiating the model is expensive, so storing as a class variable.
      @@model ||= RorEmbeddings::Model.new # rubocop:disable Style/ClassVars
    end

    # @param query [String] the query (organization) to search for
    # @param limit [Integer] the maximum number of results to return
    def call(query:, limit: 5)
      query_embedding = @@model.embed_single(query)
      Ror.select(:id, :ror_id, :label, :location).nearest_neighbors(:embedding,
                                                                    Neighbor::SparseVector.new(query_embedding),
                                                                    distance: 'inner_product').limit(limit)
    end

    # Splits the query and searches on different chunks of the query.
    # @param query [String] the query (organization) to search for
    # @param limit [Integer] the maximum number of results to return
    # rubocop:disable Metrics/AbcSize
    def call_split(query:, limit: 5)
      query_parts = query.split(', ')
      results = (0...query_parts.length).to_a.flat_map do |query_index|
        parts_query = query_parts[query_index, query_parts.length - query_index].join(', ')
        query_embedding = @@model.embed_single(parts_query)
        Ror.select(:id, :ror_id, :label, :location).nearest_neighbors(:embedding,
                                                                      Neighbor::SparseVector.new(query_embedding),
                                                                      distance: 'inner_product').limit(limit)
      end
      results = results.sort_by(&:neighbor_distance).reverse
      results = results.uniq(&:id)
      results.take(limit)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
