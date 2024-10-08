# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeiCocinaMapperService do
  subject(:cocina_object) { described_class.call(tei_ng_xml:, related_resource_citation:) }

  let(:related_resource_citation) { nil }

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
                                                            organization: 'Library of Congress'
                                                          }]),
              CocinaDescriptionSupport.person_contributor(forename: 'Lynn Silipigni',
                                                          surname: 'Connaway')
            ],
            note: [
              CocinaDescriptionSupport.note(type: 'abstract',
                                            value: 'In order for collection development librarians to justify the adoption of electronic books ...') # rubocop:disable Layout/LineLength
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
      expect(cocina_object).to equal_cocina(expected)
    end
  end

  context 'with a preprint PDF' do
    let(:tei_ng_xml) { Nokogiri::XML(File.read('spec/fixtures/tei/preprint.xml')) }

    let(:related_resource_citation) { citation_fixture }

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
                                                            organization: 'Library of Congress'
                                                          }]),
              CocinaDescriptionSupport.person_contributor(forename: 'Lynn Silipigni',
                                                          surname: 'Connaway')
            ],
            note: [
              CocinaDescriptionSupport.note(type: 'abstract',
                                            value: 'In order for collection development librarians to justify the adoption of electronic books ...') # rubocop:disable Layout/LineLength
            ],
            event: [],
            subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries']),
            relatedResource: [
              {
                identifier: [CocinaDescriptionSupport.doi_identifier(doi: doi_fixture)],
                note: [CocinaDescriptionSupport.related_resource_note(citation: citation_fixture)]
              }
            ]
          },
          version: 1,
          identification: { sourceId: 'shroom:object-0' },
          administrative: { hasAdminPolicy: Settings.apo }
        }
      )
    end
    let(:title) { title_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
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
                                                          surname: 'Littman')
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
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
