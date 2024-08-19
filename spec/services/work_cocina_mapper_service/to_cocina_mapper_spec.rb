# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkCocinaMapperService::ToCocinaMapper do
  subject(:cocina_object) { described_class.call(work:) }

  let(:work) do
    WorkForm.new(
      title: title_fixture,
      authors: [author1, author2],
      abstract: abstract_fixture,
      published_year: 2004,
      published_month: 10,
      published_day: 1,
      publisher: 'American Library Association',
      keywords: [
        KeywordForm.new(value: 'Electronic books'),
        KeywordForm.new(value: 'Academic libraries')
      ]
    )
  end
  let(:author1) do
    AuthorForm.new(
      first_name: 'Justin',
      last_name: 'Littman',
      affiliations: [AffiliationForm.new(organization: 'Library of Congress',
                                         department: 'Repository Development Center')]
    )
  end
  let(:author2) { AuthorForm.new(first_name: 'Lynn', last_name: 'Connaway') }

  let(:mapper) { described_class.new(work:) }

  describe '#call' do
    let(:expected) { create_request_dro }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected)
    end
  end
end
