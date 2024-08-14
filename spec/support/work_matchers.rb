# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :equal_work do |expected|
  match do |actual|
    JSON.parse(actual.to_json) == JSON.parse(expected.to_json)
  end

  failure_message do |actual|
    SuperDiff::EqualityMatchers::Hash.new(
      expected: JSON.parse(expected.to_json).deep_symbolize_keys,
      actual: JSON.parse(actual.to_json).deep_symbolize_keys
    ).fail
  rescue StandardError => e
    "ERROR in WorkMatchers: #{e}"
  end
end
