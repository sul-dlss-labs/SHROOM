# frozen_string_literal: true

module Sdr
  # Service to deposit a work via SDR API.
  class DepositService
    class Error < StandardError; end

    def self.call(...)
      new(...).call
    end

    # @param [Cocina::Models::RequestDRO] cocina_object
    # @param [Work] work
    def initialize(cocina_object:, work:)
      @cocina_object = cocina_object
      @work = work
    end

    # @raise [Error] if there is an error depositing the work
    def call
      @cocina_object = cocina_object.new(identification: identification_params,
                                         structural: structural_params)
      job_id = deposit
      job_status = await_job_status(job_id:)

      work.update!(druid: job_status.druid)
    end

    private

    attr_reader :cocina_object, :work

    delegate :version, to: :cocina_object
    delegate :work_files, to: :work

    def deposit
      # upload_responses is an Array<DirectUploadResponse>.
      upload_responses = SdrClient::RedesignedClient::UploadFiles.upload(file_metadata:,
                                                                         filepath_map:)
      new_request_dro = SdrClient::RedesignedClient::UpdateDroWithFileIdentifiers.update(request_dro: cocina_object,
                                                                                         upload_responses:)

      SdrClient::RedesignedClient::CreateResource.run(accession: true,
                                                      #  assign_doi: options[:assign_doi],
                                                      #  user_versions: options[:user_versions],
                                                      metadata: new_request_dro)
    end

    def await_job_status(job_id:)
      job_status = SdrClient::RedesignedClient::JobStatus.new(job_id:)
      raise Error, "Deposit failed: #{job_status.errors.join('; ')}" unless job_status.wait_until_complete

      job_status
    end

    def identification_params
      { sourceId: "shroom:object-#{work.id}" }
    end

    # @return [Hash<String,DirectUploadRequest>] file_metadata map of relative filepaths to file metadata
    def file_metadata
      work_files.each_with_object({}) do |file, hash|
        hash[file.filename] = direct_upload_request_for(file)
      end
    end

    # @return [Hash<String,String>] map of relative filepaths to absolute filepaths
    def filepath_map
      work_files.each_with_object({}) do |file, hash|
        hash[file.filename] = file.path
      end
    end

    def direct_upload_request_for(file)
      SdrClient::RedesignedClient::DirectUploadRequest.new(
        checksum: file.checksum,
        byte_size: file.byte_size,
        content_type: file.content_type,
        filename: file.filename.to_s
      )
    end

    def structural_params
      {
        contains: work_files.map { |file| file_set_params_for(file) }
      }
    end

    def file_set_params_for(file)
      {
        type: Cocina::Models::FileSetType.file,
        version:,
        label: file.filename,
        structural: {
          contains: [file_params_for(file)]
        }
      }
    end

    def file_params_for(file)
      {
        type: Cocina::Models::ObjectType.file,
        version:,
        label: file.filename,
        filename: file.filename,
        access: { view: 'world', download: 'world' },
        administrative: { publish: true, sdrPreserve: true, shelve: true },
        hasMimeType: file.content_type,
        hasMessageDigests: [
          { type: 'md5', digest: base64_to_hexdigest(file.checksum) },
          { type: 'sha1', digest: Digest::SHA1.file(file.path).hexdigest }
        ],
        size: file.byte_size
      }.compact
    end

    def base64_to_hexdigest(base64)
      Base64.decode64(base64).unpack1('H*')
    end
  end
end
