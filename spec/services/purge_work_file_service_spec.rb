# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeWorkFileService do
  let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'preprint.pdf'), 'application/pdf') }
  let(:work_file) { WorkFile.create!(file: file) }
  let(:work_file_path) { Pathname.new(ActiveStorage::Blob.service.path_for(work_file.file.blob.key)) }

  it 'removes the file and storage path' do
    expect(work_file_path).to exist
    described_class.purge(work_file:)
    expect(work_file_path).not_to exist
    expect(work_file_path.parent).not_to exist
  end
end
