# frozen_string_literal: true

require 'google/cloud/storage'

module Dataset
  # Represents a single file in the dataset
  class File
    class Error < StandardError; end

    def initialize(metadata:, store_path: 'tmp/dataset')
      @metadata = metadata
      @store_path = store_path

      write_metadata
      fetch_pdf
      extract_text
      normalize_text

      Google::Cloud::Storage.configure do |config|
        config.project_id  = 'sul-ai-sandbox'
        config.credentials = JSON.parse(Rails.application.credentials.google_cloud.service_account_credentials)
      end
    end

    def pdf_filename
      metadata['pdf_path']
    end

    def pdf_filepath
      pdf_pathname.to_s
    end

    def text_filepath
      text_pathname.to_s
    end

    def normalized_text_filepath
      normalized_text_pathname.to_s
    end

    def text
      @text ||= text_pathname.read
    end

    def title
      @title ||= normalize_metadata(metadata['title'])
    end

    def authors
      @authors ||= metadata['authorships'].map { |author| normalize_metadata(author['raw_author_name']) }
    end

    def affiliations
      @affiliations ||= metadata['authorships'].flat_map do |authorship|
        authorship['raw_affiliation_strings'].map { |affiliation| normalize_metadata(affiliation) }
      end.uniq
    end

    def affiliations_for(author:)
      matching_authorship = metadata['authorships'].find { |authorship| authorship['raw_author_name'] == author }
      return [] unless matching_authorship

      matching_authorship['raw_affiliation_strings'].map { |affiliation| normalize_metadata(affiliation) }.uniq
    end

    def abstract
      @abstract ||= build_abstract
    end

    def match?(value)
      value.present? && normalized_text.include?(value.downcase)
    end

    attr_reader :metadata, :store_path, :normalized_text

    private

    def pdf_pathname
      @pdf_pathname ||= Pathname.new(::File.join(store_path, pdf_filename))
    end

    def text_pathname
      @text_pathname ||= Pathname.new(pdf_pathname.to_s.sub(/\.pdf$/, '.txt'))
    end

    def normalized_text_pathname
      @normalized_text_pathname ||= Pathname.new(pdf_pathname.to_s.sub(/\.pdf$/, '.normalized.txt'))
    end

    def alto_xml_pathname
      @alto_xml_pathname ||= Pathname.new(pdf_pathname.to_s.sub(/\.pdf$/, '.xml'))
    end

    def metadata_pathname
      @metadata_pathname ||= Pathname.new(pdf_pathname.to_s.sub(/\.pdf$/, '.metadata.json'))
    end

    def fetch_pdf
      return if pdf_pathname.exist?

      cs_storage = Google::Cloud::Storage.new
      cs_bucket = cs_storage.bucket('cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4')
      cs_file = cs_bucket.file("preprints/#{metadata['pdf_path']}")
      cs_file.download(pdf_pathname)
    end

    # rubocop:disable Metrics/AbcSize
    def extract_text
      return if text_pathname.exist?

      # Make sure pdfalto is compiled and in the PATH
      system_call("pdfalto -noImage -noLineNumbers -f 1 -l 3 #{pdf_pathname}")
      system_call("xsltproc lib/alto2txt.xsl #{alto_xml_pathname} > #{text_pathname}")
    rescue StandardError => e
      alto_xml_pathname.unlink if alto_xml_pathname.exist?
      text_pathname.unlink if text_pathname.exist?
      raise Dataset::File::Error, "Error extracting text from #{pdf_filename}: #{e}"
    end
    # rubocop:enable Metrics/AbcSize

    def system_call(command, timout: 30)
      Timeout.timeout(timout) do
        Open3.popen3(command) do |_stdin, _stdout, stderr, wait_thr|
          exit_status = wait_thr.value # Process::Status object returned.
          raise Dataset::File::Error, "Error running command: #{command}: #{stderr.read}" unless exit_status.success?
        end
      end
    end

    def write_metadata
      return if metadata_pathname.exist?

      metadata_pathname.dirname.mkpath
      metadata_pathname.write(JSON.pretty_generate(metadata))
    end

    def normalize_text
      @normalized_text = text
                         .downcase
                         .gsub("-\n", '')
                         .tr("\n", ' ')
                         .gsub(/ {2,}/, ' ')
      normalized_text_pathname.write(@normalized_text)
    end

    def normalize_metadata(value)
      value
        .delete_suffix('.')
        .gsub(/ {2,}/, ' ')
        .tr("\n", ' ')
    end

    def build_abstract
      return unless metadata['abstract_inverted_index']

      words = []
      metadata['abstract_inverted_index'].each do |word, positions|
        positions.each do |position|
          words[position] = word
        end
      end
      words.join(' ')
    end
  end
end
