# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EvaluatorService do
  let(:errors) { described_class.call(expected:, actual:) }

  let(:expected) { WorkForm.new.from_json(expected_attrs.to_json) }
  let(:actual) do
    WorkForm.new.from_json(expected_attrs.deep_dup.to_json)
  end
  let(:expected_attrs) do
    {
      title: title_fixture,
      authors: [author1, author2],
      abstract: abstract_fixture,
      keywords: [
        { value: 'Electronic books' },
        { value: 'Academic libraries' }
      ],
      related_resource_citation: citation_fixture,
      related_resource_doi: doi_fixture
    }
  end

  let(:author1) do
    {
      first_name: 'Justin',
      last_name: 'Littman',
      affiliations: [{ organization: 'Library of Congress',
                       department: 'Repository Development Center' }],
      orcid: 'https://orcid.org/0000-0003-1527-0030'
    }
  end
  let(:author2) { { first_name: 'Lynn', last_name: 'Connaway' } }

  context 'when a match' do
    it 'returns no errors' do
      expect(errors).to be_empty
    end
  end

  context 'when title mismatch' do
    before do
      actual.title = 'Different Title'
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Title does not match'
    end
  end

  context 'when keyword missing' do
    before do
      actual.keywords = [actual.keywords.first]
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Keywords do not match'
    end
  end

  context 'when extra keyword' do
    before do
      actual.keywords << KeywordForm.new(value: 'Extra keyword')
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Keywords do not match'
    end
  end

  context 'when abstract mismatch' do
    before do
      actual.abstract = 'Different Abstract'
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Abstract does not match'
    end
  end

  context 'when author missing' do
    before do
      actual.authors = [actual.authors.first]
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Authors do not match'
    end
  end

  context 'when extra author' do
    before do
      actual.authors << AuthorForm.new(first_name: 'Extra', last_name: 'Author')
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Authors do not match'
    end
  end

  context 'when orcid mismatch' do
    before do
      actual.authors.first.orcid = 'https://orcid.org/0000-0000-0000-0000'
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Orcid does not match for author Justin Littman'
    end
  end

  context 'when affiliation missing' do
    before do
      actual.authors.first.affiliations = []
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Affiliations do not match for author Justin Littman'
    end
  end

  context 'when extra affiliations' do
    before do
      actual.authors.first.affiliations << AffiliationForm.new(organization: 'Stanford University')
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Affiliations do not match for author Justin Littman'
    end
  end

  context 'when related resource DOI mismatch' do
    before do
      actual.related_resource_doi = 'https://doi.org/10.1234/5678'
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Related Resource Doi does not match'
    end
  end

  context 'when related resource citation mismatch' do
    before do
      actual.related_resource_citation = 'Different Citation'
    end

    it 'returns an error' do
      expect(errors.length).to eq 1
      expect(errors.first.error).to eq 'Related Resource Citation does not match'
    end
  end
end
