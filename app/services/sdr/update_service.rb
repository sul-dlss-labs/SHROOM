# frozen_string_literal: true

module Sdr
  # Service to update a work via SDR API.
  class UpdateService
    class Error < StandardError; end

    def self.call(...)
      new(...).call
    end

    # @param [Cocina::Models::DRO] cocina_object new version of the cocina object
    # @param [Cocina::Models::DRO] existing_cocina_object existing version of the cocina object
    # @param [Cocina::Models::RequestDRO,Cocina::Models::DRO] cocina_object
    # @param [Work] work
    def initialize(cocina_object:, existing_cocina_object:, work:)
      @cocina_object = cocina_object
      @existing_cocina_object = existing_cocina_object
      @work = work
    end

    # @raise [Error] if there is an error updating the work
    def call
      # Currently cannot update files, so just using existing structural.
      new_structural = cocina_object.structural.new(contains: existing_cocina_object.structural.contains)
      @cocina_object = cocina_object.new(structural: new_structural)
      job_id = update
      await_job_status(job_id:)
      job_id
    end

    private

    attr_reader :cocina_object, :work, :existing_cocina_object

    delegate :version, to: :cocina_object
    delegate :work_files, to: :work

    def update
      SdrClient::RedesignedClient::UpdateResource.run(model: cocina_object)
    end

    def await_job_status(job_id:)
      job_status = SdrClient::RedesignedClient::JobStatus.new(job_id:)
      raise Error, "Deposit failed: #{job_status.errors.join('; ')}" unless job_status.wait_until_complete

      job_status
    end
  end
end
