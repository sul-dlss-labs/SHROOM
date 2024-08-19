# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeiCocinaMapperService do
  let(:tei_ng_xml) { Nokogiri::XML(File.read('spec/fixtures/tei/preprint.xml')) }

  let(:expected) do
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.object,
        label: title,
        description: {
          title: CocinaDescriptionSupport.title(title:),
          contributor: [
            CocinaDescriptionSupport.person_contributor(forename: 'Justin',
                                                        surname: 'Littman',
                                                        affiliations: [{
                                                          organization: 'Library of Congress',
                                                          department: 'Repository Development Center'
                                                        }]),
            CocinaDescriptionSupport.person_contributor(forename: 'Lynn',
                                                        surname: 'Connaway')
          ],
          note: [
            CocinaDescriptionSupport.note(type: 'abstract',
                                          value: 'In order for collection development librarians to justify the adoption of electronic books ...') # rubocop:disable Layout/LineLength
          ],
          event: [
            CocinaDescriptionSupport.event_date(date_type: 'publication',
                                                date_value: '2004-10-01'),
            CocinaDescriptionSupport.event_contributor(contributor_name_value: 'American Library Association')
          ],
          subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries'])
        },
        version: 1,
        identification: { sourceId: 'shroom:object-0' },
        administrative: { hasAdminPolicy: Settings.apo }
      }
    )
  end
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }

  it 'maps to cocina' do
    expect(described_class.call(tei_ng_xml:)).to equal_cocina(expected)
  end
end
