# frozen_string_literal: true

# Run an evaluation, comparing groundtruth metadata against metadata from a metadata extraction service.
# The groundtruth metadata is in a JSONL file, and the metadata extraction service is a class that
# extracts metadata from a file.
class EvaluationRunner
  def self.call(...)
    new(...).call
  end

  def initialize(groundtruth_json_filepath: 'export.jsonl', dataset_path: 'dataset',
                 metadata_extraction_service: MetadataExtractionService, limit: nil, output: $stdout)
    @groundtruth_json_filepath = groundtruth_json_filepath
    @dataset_path = dataset_path
    @metadata_extraction_service = metadata_extraction_service
    @limit = limit
    @output = output
  end

  def call
    runner_works.each do |runner_work|
      work_file_path = File.join(dataset_path, runner_work.filename)
      expected_work_form = runner_work.work_form
      actual_work_form = metadata_extraction_service
                         .new(logger: null_logger)
                         .from_file(path: work_file_path,
                                    published: expected_work_form.published?)
      errors = EvaluatorService.call(expected: expected_work_form, actual: actual_work_form)
      output_errors(errors:, runner_work:)
    end
    nil
  end

  private

  attr_reader :groundtruth_json_filepath, :dataset_path, :metadata_extraction_service, :limit, :output

  def lines
    lines = nil
    File.open(groundtruth_json_filepath, 'r') do |file|
      lines = file.readlines
    end
    lines = lines.take(limit) if limit
    lines
  end

  def runner_works
    lines.map { |line| RunnerWork.new(line:) }
  end

  # rubocop:disable Metrics/AbcSize
  def output_errors(errors:, runner_work:)
    if errors.empty?
      output.puts "PASS: #{runner_work.druid}"
    else
      output.puts "FAIL: #{runner_work.druid} (#{runner_work.filename})"
      errors.each do |error|
        output.puts "  #{error.error}:"
        output.puts "    expected: #{error.expected}"
        output.puts "    actual:   #{error.actual}"
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def null_logger
    @null_logger ||= Logger.new('/dev/null')
  end

  # Encapsulates a line of JSON from the groundtruth JSONL file.
  class RunnerWork
    def initialize(line:)
      @line = line
    end

    def filename
      line_hash['filename']
    end

    def druid
      line_hash['druid']
    end

    def work_form
      WorkForm.new.from_json(line_hash.except('filename', 'druid', 'work_id').to_json)
    end

    private

    attr_reader :line

    def line_hash
      @line_hash ||= JSON.parse(line)
    end
  end
end
