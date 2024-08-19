# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService do
  let(:cocina_request_object) do
    Cocina::Models.build_request({
                                   type: Cocina::Models::ObjectType.object,
                                   label: title_fixture,
                                   description: { title: CocinaDescriptionSupport.title(title: title_fixture) },
                                   version: 1,
                                   identification: { sourceId: 'shroom:object-0' },
                                   administrative: { hasAdminPolicy: Settings.apo },
                                   access: { view: 'world', download: 'world' },
                                   structural: { contains: [] }
                                 })
  end
  let(:work_form) { WorkForm.new(title: title_fixture) }

  describe '.to_cocina' do
    it 'maps to cocina' do
      expect(described_class.to_cocina(work_form:)).to equal_cocina(cocina_request_object)
    end
  end

  describe '.to_work' do
    context 'when roundtrippable request' do
      it 'maps to work form' do
        expect(described_class.to_work(cocina_object: cocina_request_object)).to equal_work(work_form)
      end
    end

    context 'when roundtrippable' do
      let(:cocina_object) { create_dro_with_structural }

      it 'maps to work form' do
        expect(described_class.to_work(cocina_object:)).to be_a(WorkForm)
      end
    end

    context 'when not roundtrippable' do
      it 'raises UnmappableError' do
        expect do
          described_class.to_work(cocina_object: cocina_request_object.new(geographic: { iso19139: '' }))
        end.to raise_error(described_class::UnmappableError)
      end
    end
  end
end
