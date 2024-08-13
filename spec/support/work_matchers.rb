require 'rspec/expectations'

RSpec::Matchers.define :equal_work do |expected|
  match do |actual|
    JSON.parse(actual.to_json) == JSON.parse(expected.to_json)
  end
end
