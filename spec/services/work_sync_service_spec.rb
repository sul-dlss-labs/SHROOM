# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkSyncService do
  subject(:work_sync_service) { described_class.new(work:, cocina_object:) }

  let(:work) { create(:work, title: 'Change me') }
  let(:cocina_object) { create_dro }

  describe '#call' do
    context 'when the Collection exists' do
      let!(:collection) { create(:collection) }

      it 'updates the work' do
        work_sync_service.call

        expect(work.reload.title).to eq title_fixture
        expect(work.collection).to eq collection
      end
    end

    context 'when the Collection does not exist' do
      let(:collection_cocina_object) { create_collection }

      before do
        allow(Sdr::Repository).to receive(:find).and_return(collection_cocina_object)
      end

      it 'creates the Collection and updates the work' do
        work_sync_service.call

        expect(work.reload.title).to eq title_fixture
        new_collection = Collection.find_by!(druid: collection_druid_fixture)
        expect(new_collection.title).to eq collection_title_fixture
        expect(work.collection).to eq new_collection
      end
    end
  end
end
