# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToWorkMapper do
  subject(:work) { described_class.call(cocina_object:) }

  let(:cocina_object) { create_request_dro }

  let(:author1) do
    AuthorForm.new(
      first_name: 'Justin',
      last_name: 'Littman',
      affiliations: [AffiliationForm.new(organization: 'Library of Congress',
                                         department: 'Repository Development Center')],
      orcid: 'https://orcid.org/0000-0003-1527-0030'
    )
  end
  let(:author2) { AuthorForm.new(first_name: 'Lynn', last_name: 'Connaway') }

  describe '#call' do
    let(:expected) do
      WorkForm.new(
        title: title_fixture,
        authors: [author1, author2],
        abstract: abstract_fixture,
        published_year: 2004,
        published_month: 10,
        published_day: 1,
        publisher: 'American Library Association',
        doi: doi_fixture,
        keywords: [
          KeywordForm.new(value: 'Electronic books'),
          KeywordForm.new(value: 'Academic libraries')
        ],
        related_resource_citation: citation_fixture,
        related_resource_doi: doi_fixture,
        collection_druid: collection_druid_fixture
      )
    end

    it 'maps to work' do
      expect(work).to equal_work expected
    end

    context 'when published year only' do
      let(:cocina_object) { create_request_dro.new(description:) }
      let(:description) do
        {
          title: CocinaDescriptionSupport.title(title: title_fixture),
          event: [
            CocinaDescriptionSupport.event_date(date_type: 'publication',
                                                date_value: '2004')
          ]
        }
      end

      it 'maps to work' do
        expect(work.published_year).to eq 2004
        expect(work.published_month).to be_nil
        expect(work.published_day).to be_nil
      end
    end
  end
end
