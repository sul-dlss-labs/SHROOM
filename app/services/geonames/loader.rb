# frozen_string_literal: true

# Module for Geonames
module Geonames
  # Load Geonames data into the database
  class Loader
    def self.call(...)
      new(...).call
    end

    def initialize(path: 'allCountries.txt', limit: nil, group_size: 1000)
      @path = path
      @limit = limit
      @group_size = group_size
    end

    def call
      Geoname.delete_all
      index = 0
      all_names.in_groups_of(group_size, false) do |names_group|
        Rails.logger.info("Inserting #{index * group_size}")
        Geoname.insert_all!(names_group.map { |name| { name: } })

        index += 1
      end
      nil
    end

    private

    attr_reader :path, :limit, :group_size

    def all_names
      index = 0
      all_names = Set.new
      File.open(path, 'r').each_line do |line|
        parts = line.split("\t")
        next unless %w[A P].include?(parts[6])

        all_names.merge(names_for(parts))

        index += 1
        break if limit == index
      end
      all_names.to_a
    end
  end

  def names_for(parts)
    [parts[1], parts[2]].tap do |names|
      names.concat(parts[3].split(','))
    end.map(&:downcase)
  end
end
