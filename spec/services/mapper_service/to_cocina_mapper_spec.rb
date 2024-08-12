require 'rails_helper'

RSpec.describe MapperService::ToCocinaMapper do
  subject(:cocina_object) { described_class.call(work: work) }

  let(:work) { Work.new(title:) }
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
  let(:mapper) { described_class.new(work: work) }

  describe '#call' do
    let(:expected) do
      Cocina::Models.build_request({
        type: Cocina::Models::ObjectType.object,
        label: title,
        description: { title: [ { value: title } ] },
        version: 1,
        identification: { sourceId: "shroom:object-1" },
        administrative: { hasAdminPolicy: Settings.apo }
    }
      )
    end


    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
