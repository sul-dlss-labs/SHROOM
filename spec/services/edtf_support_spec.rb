require 'rails_helper'

RSpec.describe EdtfSupport do
  describe '.to_edtf' do
    context 'when year is nil' do
      it 'returns nil' do
        expect(described_class.to_edtf(year: nil)).to be_nil
      end
    end

    context 'when only year' do
      it 'returns edtf' do
        expect(described_class.to_edtf(year: 2004)).to eq '2004'
      end
    end

    context 'when only year and month' do
      it 'returns edtf' do
        expect(described_class.to_edtf(year: 2004, month: 10)).to eq '2004-10'
      end
    end

    context 'when year, month and day' do
      it 'returns edtf' do
        expect(described_class.to_edtf(year: 2004, month: 10, day: 1)).to eq '2004-10-01'
      end
    end
  end
end
