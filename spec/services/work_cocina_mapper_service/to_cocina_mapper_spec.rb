# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToCocinaMapper do
  subject(:cocina_object) { described_class.call(work_form:, druid:, version:, source_id:) }

  let(:druid) { nil }
  let(:version) { 1 }
  let(:source_id) { nil }

  let(:work_form) do
    WorkForm.new(
      title: title_fixture,
      authors: [author1, author2],
      abstract: abstract_fixture,
      keywords: [
        KeywordForm.new(value: 'Electronic books'),
        KeywordForm.new(value: 'Academic libraries')
      ],
      related_resource_citation: citation_fixture,
      related_resource_doi: doi_fixture,
      collection_druid: collection_druid_fixture
    )
  end
  let(:author1) do
    AuthorForm.new(
      first_name: 'Justin',
      last_name: 'Littman',
      affiliations: [AffiliationForm.new(organization: 'Library of Congress')]
    )
  end
  let(:author2) { AuthorForm.new(first_name: 'Lynn', last_name: 'Connaway') }

  describe '#call' do
    context 'when a new work' do
      let(:expected) { create_request_dro }

      it 'maps to cocina' do
        expect(cocina_object).to equal_cocina(expected)
      end
    end

    context 'when an existing work' do
      let(:druid) { druid_fixture }
      let(:version) { 2 }
      let(:expected) { create_dro }
      let(:source_id) { 'shroom:object-4' }

      it 'maps to cocina' do
        expect(cocina_object).to equal_cocina(expected)
      end
    end
  end
end
