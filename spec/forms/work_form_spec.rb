# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  describe 'validations' do
    let(:work) do
      described_class.new(
        title:,
        authors:
      )
    end

    let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
    let(:authors) { [] }

    context 'when title is not present' do
      let(:title) { nil }

      it 'is invalid' do
        expect(work).not_to be_valid
        expect(work.errors[:title]).to include("can't be blank")
      end
    end

    context 'when author is invalid' do
      let(:authors) { [AuthorForm.new(first_name: 'Justin')] }

      it 'is invalid' do
        expect(work).not_to be_valid
        expect(work.errors[:'authors.0.last_name']).to include("can't be blank")
      end
    end
  end

  describe 'normalization' do
    context 'when authors are blank' do
      let(:work) { described_class.new(authors: [author1, author2]) }
      let(:author1) { AuthorForm.new(first_name: 'Justin', last_name: 'Littman') }
      let(:author2) { AuthorForm.new }

      before do
        work.valid? # trigger normalization
      end

      it 'removes them' do
        expect(work.authors).to eq [author1]
      end
    end
  end

  describe 'json serialization' do
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

    let(:work_form) do
      described_class.new(
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

    it 'serializes and deserializes to json' do
      expect(described_class.new.from_json(work_form.to_json)).to equal_work work_form
    end
  end
end
