# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrobidService do
  describe '.from_file' do
    subject(:work) { described_class.from_file(path: 'spec/fixtures/files/preprint.pdf') }

    context 'when successful response' do
      before do
        stub_request(:post, 'http://localhost:8070/api/processHeaderDocument')
          .with(
            headers: {
              'Accept' => 'application/xml'
            }
          )
          .to_return(status: 200, body: File.read('spec/fixtures/tei/preprint.xml'), headers: {
                       'Content-Type' => 'application/xml'
                     })
      end

      it 'calls grobid web service and returns a Work' do
        expect(work).to be_a(WorkForm)
      end
    end

    context 'when unsuccessful response' do
      before do
        stub_request(:post, 'http://localhost:8070/api/processHeaderDocument')
          .with(
            headers: {
              'Accept' => 'application/xml'
            }
          )
          .to_return(status: 500)
      end

      it 'raises a GrobidService::Error' do
        expect { work }.to raise_error(described_class::Error)
      end
    end
  end

  describe '.from_doi' do
    subject(:work) { described_class.from_doi(doi: 'https://doi.org/10.1177/1940161218781254') }

    context 'when successful response' do
      before do
        stub_request(:post, 'http://localhost:8070/api/processCitation')
          .with(
            body: { 'citations' => 'https://doi.org/10.1177/1940161218781254', 'consolidateCitations' => '1' },
            headers: {
              'Accept' => 'application/xml',
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(status: 200, body: File.read('spec/fixtures/tei/citation.xml'), headers: {
                       'Content-Type' => 'application/xml'
                     })
      end

      it 'calls grobid web service and returns a Work' do
        expect(work).to be_a(WorkForm)
      end
    end
  end
end
