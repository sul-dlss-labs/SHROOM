# frozen_string_literal: true

# Compares an expected Work Form against an actual Work Form.
class EvaluatorService
  EvaluationResult = Struct.new(:error, :expected, :actual, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  # @param [WorkForm] expected groundtruth for the work
  # @param [WorkForm] actual
  def initialize(expected:, actual:)
    @expected = expected
    @actual = actual
    @results = []
  end

  # @return [Array<Result>] results of the evaluation
  def call
    evaluate_field(field: :title)
    evaluate_field(field: :abstract)
    evaluate_keywords
    evaluate_authors
    evaluate_field(field: :related_resource_citation)
    evaluate_field(field: :related_resource_doi)

    results
  end

  private

  attr_reader :expected, :actual, :results

  def evaluate_field(field:, expected_item: expected, actual_item: actual, for_label: nil)
    expected_value = expected_item.send(field)
    actual_value = actual_item.send(field)
    return true if expected_value == actual_value

    results << EvaluationResult.new(error: error_for(field:, for_label:), expected: expected_value,
                                    actual: actual_value)
    false
  end

  def error_for(field:, for_label:)
    error = "#{field.to_s.titleize} #{field.to_s.end_with?('s') ? 'do' : 'does'} not match"
    error += " for #{for_label}" if for_label
    error
  end

  def evaluate_keywords
    evaluate_sets(field: :keywords, map_func: ->(keyword) { keyword.value })
  end

  def evaluate_authors
    return unless evaluate_sets(field: :authors,
                                map_func: ->(author) { [author.first_name, author.last_name].join(' ') })

    expected.authors.each_with_index do |expected_author, index|
      actual_author = actual.authors[index]
      evaluate_author(actual_author:, expected_author:)
    end
  end

  def evaluate_author(actual_author:, expected_author:)
    for_label = "author #{expected_author.first_name} #{expected_author.last_name}"
    evaluate_field(field: :orcid, expected_item: expected_author, actual_item: actual_author,
                   for_label:)
    evaluate_sets(field: :affiliations,
                  map_func: lambda { |affiliation|
                              [affiliation.department, affiliation.organization].compact.join(', ')
                            },
                  expected_item: expected_author, actual_item: actual_author, for_label:)
  end

  def evaluate_sets(field:, map_func:, for_label: nil, expected_item: expected, actual_item: actual)
    expected_set = Set.new(expected_item.send(field).map { |item| map_func.call(item) })
    actual_set = Set.new(actual_item.send(field).map { |item| map_func.call(item) })

    return true if expected_set == actual_set

    results << EvaluationResult.new(error: error_for(field:, for_label:), expected: expected_set.join(', '),
                                    actual: actual_set.join(', '))
    false
  end
end
