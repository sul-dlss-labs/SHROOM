# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToWorkMapper do
  subject(:work) { described_class.call(cocina_object:) }

  let(:cocina_object) do
    Cocina::Models.build_request(
      {
        type: Cocina::Models::ObjectType.object,
        label: title,
        description: {
          title: CocinaDescriptionSupport.title(title:),
          contributor: [
            CocinaDescriptionSupport.person_contributor(forename: 'Justin',
                                                        surname: 'Littman'),
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
  let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
  let(:author1) { Author.new(first_name: 'Justin', last_name: 'Littman') }
  let(:author2) { Author.new(first_name: 'Lynn', last_name: 'Connaway') }
  let(:abstract) { 'In order for collection development librarians to justify the adoption of electronic books ...' }

  describe '#call' do
    let(:expected) do
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

    it 'maps to work' do
      expect(work).to equal_work expected
    end
  end
end
