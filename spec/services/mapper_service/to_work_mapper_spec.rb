require 'rails_helper'

RSpec.describe MapperService::ToWorkMapper do
  subject(:work) { described_class.call(cocina_object:) }

  let(:cocina_object) do
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
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }

  describe '#call' do
    let(:expected) { Work.new(title: title) }

    it 'maps to cocina' do
      expect(work).to equal_work expected
    end
  end
end
