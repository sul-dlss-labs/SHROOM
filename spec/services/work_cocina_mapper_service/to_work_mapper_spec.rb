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
                                         department: 'Repository Development Center')]
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
        keywords: [
          KeywordForm.new(value: 'Electronic books'),
          KeywordForm.new(value: 'Academic libraries')
        ]
      )
    end

    it 'maps to work' do
      expect(work).to equal_work expected
    end
  end
end
