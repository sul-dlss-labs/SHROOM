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
    end

    # @param [String] path the path to the PDF file
    # @param [Boolean] published whether the work is a published article
    # @return [WorkForm] a Work model with metadata extracted from the PDF
    # @raise [Error] if there is an error extracting metadata from the PDF
    def from_file(path:, published: false)
      @request = FromFileRequestGenerator.new(path:, published:).call
      execute_request(published:)
    end

    # @param [String] citation for the work
    # @param [Boolean] published whether the work is a published article
    # @return [WorkForm] a Work model with metadata extracted from the PDF
    # @raise [Error] if there is an error extracting metadata from the PDF
    def from_citation(citation:, published: false)
      @request = FromCitationRequestGenerator.new(citation:, published:).call
      execute_request(published:, citation:)
    end

    def info_fields
      %i[request response content]
    end

    private

    attr_reader :request, :response, :content, :logger

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

    def execute_request(published:, citation: nil)
      @response = client.generate_content(@request)
      content_json = @response.dig('candidates', 0, 'content', 'parts', 0, 'text')
      @content = JSON.parse(content_json)
      work_form = WorkForm.new.from_json(content_json)
      work_form.published = published
      work_form.related_resource_citation = citation if published && citation
      work_form
    rescue Faraday::Error, JSON::ParserError => e
      raise MetadataExtractionService::Error, "Error extracting metadata from PDF: #{e.message}"
    end

    # Base class for generating requests to the Gemini service
    class RequestGenerator
      def initialize(published:)
        @published = published
      end

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
      def response_schema
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
                        department: {
                          type: 'string'
                        },
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
            }
          }.tap do |properties|
                        if published
                          properties[:related_resource_citation] = { type: 'string' }
                          properties[:related_resource_doi] = { type: 'string' }
                        end
                      end
        }
      end
      # rubocop:enable Metrics/MethodLength
    end

    # Generates a request to the Gemini service from a PDF file
    class FromFileRequestGenerator < RequestGenerator
      def initialize(path:, published:)
        @path = path
        super(published:)
      end

      def contents
        {
          role: 'user',
          parts: [
            {
              inline_data: {
                mime_type: 'application/pdf',
                data: Base64.strict_encode64(PdfSupport.first_pages(path: @path))
              }
            },
            { text: prompt_text }
          ]
        }
      end

      attr_reader :path

      def prompt_text
        <<~TEXT
          You are a document entity extraction specialist. Given a document, your task is to extract the text value of entities from the document.

          - The JSON schema must be followed during the extraction. Do not generate additional entities.
          - The values must only include text strings found in the document.
          - The document may be missing some entities, for example, "abstract". Omit a field when the entity is missing.
          - "first_name" should include middle names, initials, etc.
          - For "affiliation", when "department" is the same as "organization", omit "department".
          - "orcid" should be in the format of a URL, for example, https://orcid.org/0000-0003-1527-0030.
          - Remove line breaks from the "abstract", except between paragraphs.
          #{related_resource_prompt_text if published}
        TEXT
      end

      def related_resource_prompt_text
        <<~TEXT
          - "related_resource_citation" is a citation for this document. If the document does not contain a citation, generate one in APA style.
          - "related_resource_doi" is the DOI for this document, for example, 10.5860/lrts.48n4.8259.
        TEXT
      end
    end

    # Generates a request to the Gemini service from a citation
    class FromCitationRequestGenerator < RequestGenerator
      def initialize(citation:, published:)
        @citation = citation
        super(published:)
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
          - "related_resource_doi" is the DOI from this citation, for example, 10.5860/lrts.48n4.8259.
        TEXT
      end

      def response_schema
        schema = super
        schema[:properties].delete(:abstract)
        schema[:properties].delete(:keywords)
        schema[:properties].delete(:related_resource_citation)
        schema
      end
    end
  end
end
