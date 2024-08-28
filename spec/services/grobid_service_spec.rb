# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrobidService do
  describe '.from_file' do
    subject(:work) { described_class.from_file(path: 'spec/fixtures/files/preprint.pdf', preprint:) }

    let(:preprint) { false }

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

    context 'when preprint' do
      let(:preprint) { true }

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

        stub_request(:post, 'http://localhost:8070/api/processHeaderDocument')
          .with(
            headers: {
              'Accept' => 'application/x-bibtex'
            }
          )
          .to_return(status: 200, body: File.read('spec/fixtures/tei/bibtex.txt'), headers: {
                       'Content-Type' => 'application/x-bibtex'
                     })
      end

      it 'calls grobid web service and returns a Work' do
        expect(work).to be_a(WorkForm)
        expect(work.related_resource_citation).to eq(citation_fixture)
      end
    end
  end

  describe '.from_citation' do
    subject(:work) { described_class.from_citation(citation: 'https://doi.org/10.1177/1940161218781254') }

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
