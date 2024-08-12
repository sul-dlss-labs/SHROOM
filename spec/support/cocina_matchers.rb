require 'rspec/expectations'

RSpec::Matchers.define :equal_cocina do |expected|
  match do |actual|
    actual.to_json == expected.to_json
  rescue NoMethodError
    warn "Could not match cocina models because expected is not a valid JSON string: #{expected}"
    false
  end

  failure_message do |actual|
    SuperDiff::EqualityMatchers::Hash.new(
      expected: expected.to_h.deep_symbolize_keys,
      actual: JSON.parse(actual, symbolize_names: true)
    ).fail
  rescue StandardError => e
    "ERROR in CocinaMatchers: #{e}"
  end
end
