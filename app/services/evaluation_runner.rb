# frozen_string_literal: true

# Run an evaluation, comparing groundtruth metadata against metadata from a metadata extraction service.
class EvaluationRunner
  def self.call(...)
    new(...).call
  end

  def initialize(groundtruth_json_filepath: 'export.jsonl', dataset_path: 'dataset',
                 metadata_extraction_service: GrobidService, limit: nil, output: $stdout)
    @groundtruth_json_filepath = groundtruth_json_filepath
    @dataset_path = dataset_path
    @metadata_extraction_service = metadata_extraction_service
    @limit = limit
    @output = output
  end

  def call
    lines = nil
    File.open(groundtruth_json_filepath, 'r') do |file|
      lines = file.readlines
    end
    lines = lines.take(limit) if limit

    lines.each do |line|
      line_hash = JSON.parse(line)
      work_file_path = File.join(dataset_path, line_hash['filename'])
      expected_work_form = WorkForm.new.from_json(line_hash.except('filename', 'druid', 'work_id').to_json)
      # Punting on preprint for now; eventually will need to handle.
      actual_work_form = metadata_extraction_service.from_file(path: work_file_path, preprint: false,
                                                               logger: Logger.new('/dev/null'))
      errors = EvaluatorService.call(expected: expected_work_form, actual: actual_work_form)
      if errors.empty?
        output.puts "PASS: #{line_hash['druid']}"
      else
        Rails.logger.debug { "FAIL: #{line_hash['druid']} (#{line_hash['filename']})" }
        errors.each do |error|
          output.puts "  #{error.error}:"
          output.puts "    expected: #{error.expected}"
          output.puts "    actual:   #{error.actual}"
        end
      end
    end
    nil
  end

  private

  attr_reader :groundtruth_json_filepath, :dataset_path, :metadata_extraction_service, :limit
end
