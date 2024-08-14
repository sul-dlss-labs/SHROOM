# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService do
  let(:cocina_object) do
    Cocina::Models.build_request({
                                   type: Cocina::Models::ObjectType.object,
                                   label: title,
                                   description: { title: CocinaDescriptionSupport.title(title:) },
                                   version: 1,
                                   identification: { sourceId: 'shroom:object-1' },
                                   administrative: { hasAdminPolicy: Settings.apo }
                                 })
  end
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
  let(:work) { Work.new(title:) }

  describe '.to_cocina' do
    it 'maps to cocina' do
      expect(described_class.to_cocina(work:)).to equal_cocina(cocina_object)
    end
  end

  describe '.to_work' do
    context 'when roundtrippable' do
      it 'maps to work' do
        expect(described_class.to_work(cocina_object:)).to equal_work(work)
      end
    end

    context 'when not roundtrippable' do
      it 'raises UnmappableError' do
        expect do
          described_class.to_work(cocina_object: cocina_object.new(geographic: { iso19139: '' }))
        end.to raise_error(described_class::UnmappableError)
      end
    end
  end
end
