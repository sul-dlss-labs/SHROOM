require 'rails_helper'

RSpec.describe GrobidService do
  subject(:work) { described_class.call(path: 'spec/fixtures/files/preprint.pdf') }

  context 'when successful response' do
    before do
      stub_request(:post, "http://localhost:8070/api/processHeaderDocument").
         with(
           headers: {
           'Accept'=>'application/xml'
           }).
         to_return(status: 200, body: File.read('spec/fixtures/tei/preprint.xml'), headers: {
            'Content-Type' => 'application/xml'
         })
    end

    it 'calls grobid web service and returns a Work' do
      expect(work).to be_a(Work)
    end
  end

  context 'when unsuccessful response' do
    before do
      stub_request(:post, "http://localhost:8070/api/processHeaderDocument").
         with(
           headers: {
           'Accept'=>'application/xml'
           }).
         to_return(status: 500)
    end

    it 'raises a GrobidService::Error' do
      expect { work }.to raise_error(described_class::Error)
    end
  end
end
