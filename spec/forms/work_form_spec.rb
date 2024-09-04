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
end
