# frozen_string_literal: true

module Dataset
  # Generates a dataset of questions and answers from a set of articles.
  class Generator
    Result = Struct.new(:filename, :field, :question, :value, :match, keyword_init: true) do
      def match?
        match
      end
    end

    def self.call(...)
      new(...).call
    end

    # Summarize the results of the analysis.
    # For each field, returns the total number of items evaluated, the number that match, and
    # the number of unique articles that have a match.
    # rubocop:disable Metrics/AbcSize
    def self.summarize(...)
      results = new(...).call
      result_summary = {}.tap do |summary|
        results.each do |result|
          summary[result.field] ||= { total: 0, matches: 0, matches_articles: Set.new }
          summary[result.field][:total] += 1
          if result.match?
            summary[result.field][:matches] += 1
            summary[result.field][:matches_articles] << result.filename
          end
        end
      end
      result_summary.each_value do |field_summary|
        field_summary[:matches_articles] = field_summary[:matches_articles].length
      end
      result_summary
    end
    # rubocop:enable Metrics/AbcSize

    # Generates a dataset of questions and answers, optionally writing to a file.
    # rubocop:disable Metrics/AbcSize
    def self.question_dataset(limit: nil, output_filepath: nil)
      results = new(limit:).call
      question_results = results.select { |result| result.match? && result.question.present? }
                                .map do |result|
        { filename: result.filename, question: result.question, answer: result.value,
          field: result.field }
      end
      if output_filepath
        ::File.open(output_filepath, 'w') do |file|
          question_results.each do |result|
            file.write(result.to_json)
            file.write("\n")
          end
        end
      end
      question_results
    end
    # rubocop:enable Metrics/AbcSize

    def initialize(limit: nil)
      @limit = limit
    end

    def call
      files.each do |file|
        analyze(file:)
      end
      results
    end

    private

    attr_reader :limit

    def files
      @files ||= Dataset::Files.new(limit:)
    end

    def results
      @results ||= []
    end

    # rubocop:disable Metrics/AbcSize
    def analyze(file:)
      results << analyze_title(file:)
      author_results = analyze_authors(file:)
      results.concat(author_results)
      results << analyze_all_authors(author_results:, file:)
      affiliation_results = analyze_affiliations(file:)
      results.concat(affiliation_results)
      results.concat(analyze_all_affiliations_for_author(file:))
      results << analyze_all_affiliations(file:, affiliation_results:)
      results << analyze_abstract(file:)
    end
    # rubocop:enable Metrics/AbcSize

    def analyze_title(file:)
      Result.new(filename: file.pdf_filename, field: 'title', question: 'What is the title?',
                 value: file.title, match: file.match?(file.title))
    end

    def analyze_authors(file:)
      file.authors.map do |author|
        Result.new(filename: file.pdf_filename, field: 'author', value: author,
                   match: file.match?(author))
      end
    end

    def analyze_all_authors(author_results:, file:)
      all_authors_match = author_results.count(&:match?) == file.authors.length
      Result.new(filename: file.pdf_filename, field: 'all_authors', question: 'Who are the authors?',
                 value: file.authors.join('; '), match: all_authors_match)
    end

    def analyze_affiliations(file:)
      file.affiliations.map do |affiliation|
        Result.new(filename: file.pdf_filename, field: 'affiliation', value: affiliation,
                   match: file.match?(affiliation))
      end
    end

    def analyze_all_affiliations_for_author(file:)
      file.authors.map do |author|
        affiliations = file.affiliations_for(author:)
        all_affiliations_for_author_match = affiliations.all? { |affiliation| file.match?(affiliation) }
        Result.new(filename: file.pdf_filename, field: 'all_affiliations_for_author',
                   question: "What are the affiliations for #{author}?",
                   value: affiliations.join('; '), match: all_affiliations_for_author_match)
      end
    end

    def analyze_all_affiliations(file:, affiliation_results:)
      all_affiliations_match = affiliation_results.count(&:match?) == file.affiliations.length
      Result.new(filename: file.pdf_filename, field: 'all_affiliations',
                 value: file.affiliations.join('; '), match: all_affiliations_match)
    end

    def analyze_abstract(file:)
      Result.new(filename: file.pdf_filename, field: 'abstract', value: file.abstract,
                 question: 'What is the abstract?', match: file.match?(file.abstract))
    end
  end
end
