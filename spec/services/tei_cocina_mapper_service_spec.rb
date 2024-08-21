# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeiCocinaMapperService do
  context 'with a PDF' do
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

  context 'with a DOI' do
    let(:tei_ng_xml) { Nokogiri::XML(File.read('spec/fixtures/tei/citation.xml')) }

    let(:expected) do
      Cocina::Models.build_request(
        {
          type: Cocina::Models::ObjectType.object,
          label: title,
          description: {
            title: CocinaDescriptionSupport.title(title:),
            contributor: [
              CocinaDescriptionSupport.person_contributor(forename: 'Nikki',
                                                          surname: 'Usher'),
              CocinaDescriptionSupport.person_contributor(forename: 'Jesse',
                                                          surname: 'Holcomb'),
              CocinaDescriptionSupport.person_contributor(forename: 'Justin',
                                                          surname: 'Littman',
                                                          orcid: 'https://orcid.org/0000-0003-1527-0030')
            ],
            event: [
              CocinaDescriptionSupport.event_date(date_type: 'publication',
                                                  date_value: '2018-06-24'),
              CocinaDescriptionSupport.event_contributor(contributor_name_value: 'SAGE Publications')
            ]
          },
          version: 1,
          identification: { sourceId: 'shroom:object-0' },
          administrative: { hasAdminPolicy: Settings.apo }
        }
      )
    end
    let(:title) do
      'Twitter Makes It Worse: Political Journalists, Gendered Echo Chambers, and the Amplification of Gender Bias'
    end

    it 'maps to cocina' do
      expect(described_class.call(tei_ng_xml:)).to equal_cocina(expected)
    end
  end
end
