# frozen_string_literal: true

module Dataset
  # Represents the files in the dataset
  class Files
    def initialize(metadata_filepath: 'metadata.jsonl', limit: nil)
      @metadata_filepath = metadata_filepath
      @limit = limit
    end

    # rubocop:disable Metrics/AbcSize
    def each
      index = 0
      ::File.open(metadata_filepath, 'r').each_line do |line|
        break if limit && index >= limit

        metadata = JSON.parse(line)
        next unless include_file?(metadata)

        Rails.logger.info("Processing #{index + 1}: #{metadata['pdf_path']}")

        yield File.new(metadata:)
        index += 1
      rescue Dataset::File::Error
        Rails.logger.error("Error processing file: #{metadata['pdf_path']}")
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :metadata_filepath, :limit

    SKIP_ARTICLES = [
      'eprints.whiterose.ac.uk/W3008359597.pdf',
      'escholarship.org/W3045400892.pdf',
      'arxiv.org/W4280519765.pdf',
      'kclpure.kcl.ac.uk/W2944666126.pdf',
      'escholarship.org/W3004652223.pdf',
      'openresearch-repository.anu.edu.au/W3179926738.pdf',
      'www.biorxiv.org/W3205833945.pdf',
      'infoscience.epfl.ch/W4221025974.pdf',
      'escholarship.org/W2973763909.pdf',
      'escholarship.org/W2915131671.pdf',
      'openresearch-repository.anu.edu.au/W3094501799.pdf',
      'repository.library.noaa.gov/W3185871720.pdf',
      'escholarship.org/W3196660357.pdf',
      'rua.ua.es/W2980356879.pdf',
      'aura.abdn.ac.uk/W4295763360.pdf',
      'mpra.ub.uni-muenchen.de/W3157699554.pdf',
      'escholarship.org/W3025389893.pdf',
      'escholarship.org/W4380883064.pdf',
      'arxiv.org/W3010745566.pdf',
      'munin.uit.no/W4388425199.pdf',
      'hal.science/W4396560436.pdf',
      'escholarship.org/W3008406088.pdf',
      'digitalcommons.osgoode.yorku.ca/W4387780052.pdf'
    ].freeze

    def include_file?(metadata)
      return false unless metadata['type'] == 'article'
      return false unless metadata['publication_year'] >= 2019
      return false if SKIP_ARTICLES.include?(metadata['pdf_path'])

      true
    end
  end
end
