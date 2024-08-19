# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::DepositService do
  subject(:deposit_service) { described_class.call(cocina_object:, work:) }

  let(:cocina_object) { create_request_dro }
  let(:new_cocina_object) { instance_double(Cocina::Models::RequestDRO) }
  let(:work) { create(:work, :with_work_file) }
  let(:upload_responses) do
    SdrClient::RedesignedClient::DirectUploadResponse.new
  end
  let(:job_id) { '123' }
  let(:druid) { 'druid:bc123df4567' }

  let(:file_metadata) do
    { 'preprint.pdf' => SdrClient::RedesignedClient::DirectUploadRequest.new(checksum: 'Rrdj7DQxnKpcHtCQrKRu8g==',
                                                                             byte_size: 204_615,
                                                                             content_type: 'application/pdf',
                                                                             filename: 'preprint.pdf') }
  end

  let(:filepath_map) do
    { 'preprint.pdf' => work.work_files.first.path }
  end

  before do
    allow(SdrClient::RedesignedClient::UploadFiles).to receive(:upload).and_return(upload_responses)
    allow(SdrClient::RedesignedClient::UpdateDroWithFileIdentifiers).to receive(:update).and_return(new_cocina_object)
    allow(SdrClient::RedesignedClient::CreateResource).to receive(:run).and_return(job_id)
    allow(SdrClient::RedesignedClient::JobStatus).to receive(:new).and_return(job_status)
  end

  context 'when the deposit succeeds' do
    let(:job_status) { instance_double(SdrClient::RedesignedClient::JobStatus, wait_until_complete: true, druid:) }

    it 'adds the druid to the Work' do
      expect { deposit_service }.to change(work, :druid).from(nil).to(druid)

      expect(SdrClient::RedesignedClient::UploadFiles).to have_received(:upload)
        .with(file_metadata:, filepath_map:)
      expect(SdrClient::RedesignedClient::UpdateDroWithFileIdentifiers).to have_received(:update)
        .with(request_dro: cocina_object, upload_responses:)
      expect(SdrClient::RedesignedClient::CreateResource).to have_received(:run).with(
        accession: true, metadata: new_cocina_object
      )
    end
  end

  context 'when the deposit job fails' do
    let(:job_status) { instance_double(SdrClient::RedesignedClient::JobStatus, wait_until_complete: false, errors:) }

    let(:errors) { ['That did not work'] }

    it 'raises' do
      expect { deposit_service }.to raise_error(Sdr::DepositService::Error)
    end
  end
end
