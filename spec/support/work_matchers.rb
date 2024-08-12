require 'rspec/expectations'

RSpec::Matchers.define :equal_work do |expected|
  match do |actual|
    actual.attributes == expected.attributes
  end
end
