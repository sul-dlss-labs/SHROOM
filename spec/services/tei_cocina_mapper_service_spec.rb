require 'rails_helper'

RSpec.describe TeiCocinaMapperService do
  let(:tei_ng_xml) { Nokogiri::XML(File.read('spec/fixtures/tei/preprint.xml')) }

  let(:expected) do
    Cocina::Models.build_request({
        type: Cocina::Models::ObjectType.object,
        label: title,
        description: {
          title: CocinaDescriptionSupport.title(title: title),
          contributor: [
            CocinaDescriptionSupport.person_contributor(forename: 'Justin', surname: 'Littman'),
            CocinaDescriptionSupport.person_contributor(forename: 'Lynn', surname: 'Connaway')
          ]
        },
        version: 1,
        identification: { sourceId: "shroom:object-1" },
        administrative: { hasAdminPolicy: Settings.apo }
    }
      )
  end
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }

  it 'maps to cocina' do
    expect(described_class.call(tei_ng_xml: tei_ng_xml)).to equal_cocina(expected)
  end
end
