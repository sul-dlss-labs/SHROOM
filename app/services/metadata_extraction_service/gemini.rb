# frozen_string_literal: true

class MetadataExtractionService
  # Extracts metadata using the Google Gemini web service and maps to Cocina model.
  class Gemini
    def self.from_file(path:, logger: Rails.logger, published: false)
      new(logger:).from_file(path:, published:)
    end

    def self.from_citation(citation:, logger: Rails.logger, published: false)
      new(logger:).from_citation(citation:, published:)
    end

    # @param [Logger] logger
    def initialize(logger: Rails.logger)
      @logger = logger
      @contents = []
      @prompts = []
      @schemas = []
    end

    # @param [String] path the path to the PDF file
    # @param [Boolean] published whether the work is a published article
    # @return [WorkForm] a Work model with metadata extracted from the PDF
    # @raise [Error] if there is an error extracting metadata from the PDF
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def from_file(path:, published: false)
      file_data = PdfSupport.subset_pages(path:)
      request = FromFileRequestGenerator.new(file_data:, published:).call
      work_attrs = execute_request(request:, key: "from-file-#{path}}")
      Parallel.each(work_attrs['authors'], in_threads: 6) do |author_attrs|
        author = "#{author_attrs['first_name']} #{author_attrs['last_name']}"
        author_request = AuthorRequestGenerator
                         .new(file_data:,
                              author:).call
        addl_author_attrs = execute_request(request: author_request, key: "author-#{author}-#{path}")
        addl_author_attrs['affiliations'] = addl_author_attrs['affiliations'].uniq do |affiliation|
          affiliation['organization']
        end
        author_attrs.merge!(addl_author_attrs)
      end
      if published
        citation_request = CitationRequestGenerator.new(title: work_attrs['title'], file_data:).call
        citation_attrs = execute_request(request: citation_request, key: "citation-#{path}")
        citation_attrs['citation'].delete!('*') # remove any asterisks from the citation
        work_attrs.merge!(citation_attrs)
      end
      to_work_form(work_attrs:, published:)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # @param [String] citation for the work
    # @param [Boolean] published whether the work is a published article
    # @return [WorkForm] a Work model with metadata extracted from the PDF
    # @raise [Error] if there is an error extracting metadata from the PDF
    def from_citation(citation:, published: false)
      request = FromCitationRequestGenerator.new(citation:, published:).call
      work_attrs = execute_request(request:)
      to_work_form(work_attrs:, published:, citation:)
    end

    def info_fields
      %i[prompts schemas contents]
    end

    private

    attr_reader :contents, :prompts, :schemas, :logger

    def client
      @client ||= ::Gemini.new(
        credentials: {
          service: 'generative-language-api',
          api_key: Rails.application.credentials.dig(:google_cloud, :api_key),
          region: 'us-central1',
          version: 'v1beta' # system instructions are only in v1beta, not v1
        },
        options: { model: 'gemini-1.5-flash' } # using 1.5 since it supports JSON schema
      )
    end

    # rubocop:disable Metrics/AbcSize
    def execute_request(request:, key:)
      @prompts << request.dig(:contents, :parts).find { |part| part.key?(:text) }[:text]
      @schemas << request.dig(:generationConfig, :response_schema)
      content_json = Rails.cache.fetch(key, expires_in: 12.hours) do
        response = client.generate_content(request)
        response.dig('candidates', 0, 'content', 'parts', 0, 'text')
      end
      content = JSON.parse(content_json)
      @contents << content.deep_dup
      content
    rescue Faraday::Error, JSON::ParserError => e
      raise MetadataExtractionService::Error, "Error extracting metadata from PDF: #{e.message}"
    end
    # rubocop:enable Metrics/AbcSize

    def to_work_form(work_attrs:, published:, citation: nil)
      work_attrs['related_resource_doi'] = work_attrs.delete('doi')
      work_attrs['related_resource_citation'] = work_attrs.delete('citation')
      work_form = WorkForm.new.from_json(work_attrs.to_json)
      work_form.published = published
      work_form.related_resource_citation = citation if published && citation
      work_form
    end

    # Base class for generating requests to the Gemini service
    class RequestGenerator
      def call
        {
          contents:,
          safetySettings: safety_settings,
          system_instruction:,
          generationConfig: generation_config
        }
      end

      attr_reader :published

      # rubocop:disable Metrics/MethodLength
      def safety_settings
        [
          {
            category: 'HARM_CATEGORY_HATE_SPEECH',
            threshold: 'BLOCK_ONLY_HIGH'
          },
          {
            category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
            threshold: 'BLOCK_ONLY_HIGH'
          },
          {
            category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            threshold: 'BLOCK_ONLY_HIGH'
          },
          {
            category: 'HARM_CATEGORY_HARASSMENT',
            threshold: 'BLOCK_ONLY_HIGH'
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def system_instruction
        { parts: { text: system_instruction_text } }
      end

      def system_instruction_text
        <<~TEXT
          As an expert in document entity extraction, you parse documents to identify and organize specific entities from diverse sources into structured formats, following detailed guidelines for clarity and completeness.
        TEXT
      end

      def generation_config
        {
          maxOutputTokens: 8192,
          temperature: 0,
          topP: 0.95,
          response_mime_type: 'application/json',
          response_schema:
        }
      end

      # rubocop:disable Metrics/MethodLength
      def full_schema
        {
          type: 'object',
          properties: {
            title: {
              type: 'string'
            },
            authors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  first_name: {
                    type: 'string'
                  },
                  last_name: {
                    type: 'string'
                  },
                  affiliations: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        organization: {
                          type: 'string'
                        }
                      }
                    }
                  }
                }
              }
            },
            abstract: {
              type: 'string'
            },
            keywords: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  value: {
                    type: 'string'
                  }
                }
              }
            },
            citation: {
              type: 'string'
            },
            doi: {
              type: 'string'
            }
          }
        }
      end
      # rubocop:enable Metrics/MethodLength
    end

    # Generates a request to the Gemini service from a PDF file
    class FromFileRequestGenerator < RequestGenerator
      def initialize(file_data:, published:)
        @file_data = file_data
        @published = published
        super()
      end

      def contents
        {
          role: 'user',
          parts: [
            {
              inline_data: {
                mime_type: 'application/pdf',
                data: Base64.strict_encode64(file_data)
              }
            },
            { text: prompt_text }
          ]
        }
      end

      attr_reader :file_data, :published

      def response_schema
        schema = full_schema.deep_dup
        schema.dig(:properties, :authors, :items, :properties).delete(:affiliations)
        schema[:properties].delete(:citation)
        schema[:properties].delete(:doi) unless published
        schema
      end

      def prompt_text
        <<~TEXT
          You are a document entity extraction specialist. Given a document, your task is to extract the text value of entities from the document.

          - The JSON schema must be followed during the extraction. Do not generate additional entities.
          - The values must only include text strings found in the document.
          - The document may be missing some entities, for example, "abstract". Omit a field when the entity is missing.
          - "first_name" should include middle names, initials, etc. Initials should be followed by a period.
          - Remove line breaks from the "abstract", except between paragraphs.
          #{related_resource_prompt_text if published}
        TEXT
      end

      def related_resource_prompt_text
        <<~TEXT
          - "doi" is the DOI (Digital Object Identifier) for this document, for example, 10.5860/lrts.48n4.8259.
          - "doi" may be prefixed by "DOI:".
        TEXT
      end
    end

    # Generates a request to the Gemini service for more details about an author
    class AuthorRequestGenerator < RequestGenerator
      def initialize(file_data:, author:)
        @file_data = file_data
        @author = author
        super()
      end

      def contents
        {
          role: 'user',
          parts: [
            {
              inline_data: {
                mime_type: 'application/pdf',
                data: Base64.strict_encode64(file_data)
              }
            },
            { text: prompt_text }
          ]
        }
      end

      attr_reader :file_data, :author

      def response_schema
        schema = full_schema.dig(:properties, :authors, :items).deep_dup
        schema[:properties].delete(:first_name)
        schema[:properties].delete(:last_name)
        schema
      end

      def prompt_text
        <<~TEXT
          #{author} is one of the authors of this article. According to this article, what organization or organizations is #{author} affiliated with?

          Return only strings found in the article.
        TEXT
      end
    end

    # Generates a request to the Gemini service for more details about a citation
    class CitationRequestGenerator < RequestGenerator
      def initialize(title:, file_data:)
        @file_data = file_data
        @title = title
        super()
      end

      def contents
        {
          role: 'user',
          parts: [
            {
              inline_data: {
                mime_type: 'application/pdf',
                data: Base64.strict_encode64(file_data)
              }
            },
            { text: prompt_text }
          ]
        }
      end

      attr_reader :file_data, :title

      def response_schema
        schema = full_schema.deep_dup
        schema[:properties].each_key do |key|
          schema[:properties].delete(key) unless key == :citation
        end
        schema
      end

      def prompt_text
        <<~TEXT
          You are a document entity extraction specialist. Given a document, your task is to extract the text value of entities from the document.

          If there is a citation for the article titled "#{title}", return it. If there is no citation, return "".

          - The JSON schema must be followed during the extraction. Do not generate additional entities.
          - The citation may be identified by phrases such as "Cite as" or "see".
        TEXT
      end
    end

    # Generates a request to the Gemini service from a citation
    class FromCitationRequestGenerator < RequestGenerator
      def initialize(citation:, published:)
        @citation = citation
        @published = published
        super()
      end

      def contents
        {
          role: 'user',
          parts: [
            { text: prompt_text }
          ]
        }
      end

      attr_reader :citation

      def prompt_text
        <<~TEXT
          You are a document entity extraction specialist. Given a citation for a document, your task is to extract the text value of entities from the citation.

          - The JSON schema must be followed during the extraction. Do not generate additional entities.
          - The values must only include text strings found in the citation.
          - The document may be missing some entities. Omit those fields.
          - "first_name" should include middle names, initials, etc.
          - Do not include markdown or HTML in the values.
          #{related_resource_prompt_text if published}

          The citation is:
          #{citation}
        TEXT
      end

      def related_resource_prompt_text
        <<~TEXT
          - "doi" is the DOI (Digital Object Identifier) from this citation, for example, 10.5860/lrts.48n4.8259.
        TEXT
      end

      def response_schema
        schema = full_schema.deep_dup
        schema[:properties].delete(:abstract)
        schema[:properties].delete(:keywords)
        schema[:properties].delete(:citation)
        schema[:properties].delete(:doi) if published
        schema
      end
    end
  end
end
