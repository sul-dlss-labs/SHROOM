require 'rails_helper'

RSpec.describe Work do
  describe 'validations' do
    let(:work) { described_class.new(
      title:,
      published_year:,
      published_month:,
      published_day:,
      authors:
      ) }

    let(:title) { 'A Circulation Analysis Of Print Books And e-Books In An Academic Research Library' }
    let(:published_year) { 2004 }
    let(:published_month) { 10 }
    let(:published_day) { 1 }
    let(:authors) { [] }

    context 'when title is not present' do
      let(:title) { nil }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:title]).to include("can't be blank")
      end
    end

    context 'when publication year is out of range' do
      let(:published_year) { 1899 }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_year]).to include("must be in 1900..#{Date.current.year}")
      end
    end

    context 'when publication month is out of range' do
      let(:published_month) { 13 }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_month]).to include("must be in 1..12")
      end
    end

    context 'when publication day is out of range' do
      let(:published_day) { 32 }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_day]).to include("must be in 1..31")
      end
    end

    context 'when publication month is present but year is blank' do
      let(:published_year) { nil }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_month]).to include("requires a year")
      end
    end

    context 'when publication day is present but year is blank' do
      let(:published_year) { nil }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_day]).to include("requires a year and month")
      end
    end

    context 'when publication day is present but month is blank' do
      let(:published_month) { nil }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:published_day]).to include("requires a year and month")
      end
    end

    context 'when author is invalid' do
      let(:authors) { [ Author.new(first_name: 'Justin') ] }

      it 'is invalid' do
        expect(work).to be_invalid
        expect(work.errors[:'authors.0.last_name']).to include("can't be blank")
      end
    end
  end

  describe 'normalization' do
    context 'when authors are blank' do
      let(:work) { described_class.new(authors: [ author1, author2 ]) }
      let(:author1) { Author.new(first_name: 'Justin', last_name: 'Littman') }
      let(:author2) { Author.new }

      before do
        work.valid? # trigger normalization
      end

      it 'removes them' do
        expect(work.authors).to eq [ author1 ]
      end
    end
  end
end
