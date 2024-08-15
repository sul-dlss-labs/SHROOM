# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToCocinaMapper do
  subject(:cocina_object) { described_class.call(work:) }

  let(:work) do
    Work.new(
      title:,
      authors: [author1, author2],
      abstract:,
      published_year: 2004,
      published_month: 10,
      published_day: 1,
      publisher: 'American Library Association',
      keywords: [
        Keyword.new(value: 'Electronic books'),
        Keyword.new(value: 'Academic libraries')
      ]
    )
  end
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
  let(:author1) do
    Author.new(
      first_name: 'Justin',
      last_name: 'Littman',
      affiliations: [Affiliation.new(organization: 'Library of Congress', department: 'Repository Development Center')]
    )
  end
  let(:author2) { Author.new(first_name: 'Lynn', last_name: 'Connaway') }
  let(:abstract) { 'In order for collection development librarians to justify the adoption of electronic books ...' }

  let(:mapper) { described_class.new(work:) }

  describe '#call' do
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
                                                          affiliations: [
                                                            {
                                                              organization: 'Library of Congress',
                                                              department: 'Repository Development Center'
                                                            }
                                                          ]),
              CocinaDescriptionSupport.person_contributor(forename: 'Lynn',
                                                          surname: 'Connaway')
            ],
            note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract)],
            event: [
              CocinaDescriptionSupport.event_date(date_type: 'publication',
                                                  date_value: '2004-10-01'),
              CocinaDescriptionSupport.event_contributor(contributor_name_value: 'American Library Association')
            ],
            subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries'])
          },
          version: 1,
          identification: { sourceId: 'shroom:object-1' },
          administrative: { hasAdminPolicy: Settings.apo }
        }
      )
    end

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
