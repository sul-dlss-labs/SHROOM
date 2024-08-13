require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToCocinaMapper do
  subject(:cocina_object) { described_class.call(work: work) }

  let(:work) { Work.new(title:, authors: [ author1, author2 ]) }
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
  let(:author1) { Author.new(first_name: 'Justin', last_name: 'Littman') }
  let(:author2) { Author.new(first_name: 'Lynn', last_name: 'Connaway') }

  let(:mapper) { described_class.new(work: work) }

  describe '#call' do
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


    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
