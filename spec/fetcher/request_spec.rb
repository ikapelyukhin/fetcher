require 'spec_helper'
require 'fetcher'

RSpec.describe Fetcher::Request do
  let(:target_dir) { Dir.mktmpdir }
  let(:logger) { Logger.new('/dev/null') }
  let(:url) { 'https://example.org/test' }

  subject(:request) { Fetcher::Request.new(logger, target_dir, url) }

  describe '#on_body_cb' do
    context 'when errors occur while writing chunks' do
      it 'aborts the request' do
        expect(request).to receive(:create_temp_file).and_raise('Something went wrong')
        expect(request.send(:on_body_cb, nil, nil)).to eq(:abort)
      end
    end
  end

  describe '#on_complete_cb' do
    let(:response) { instance_double('Typhoeus::Response') }
    let(:error_message) { 'Something went wrong' }

    context 'when request fails without receiving a response' do
      it 'logs an error message' do
        expect(response).to receive(:success?).and_return(false)
        expect(response).to receive(:code).and_return(0)
        expect(response).to receive(:return_message).and_return(error_message)
        expect(logger).to receive(:error).with("#{url}: #{error_message}")
        request.send(:on_complete_cb, response)
      end
    end

    context 'when exceptions are raised in the callback' do
      let(:file) { instance_double('File') }

      it 'logs an error and cleans up the temp file' do
        expect(file).to receive(:close).and_raise(error_message)
        expect(request).to receive(:cleanup_temp_file)
        expect(logger).to receive(:error).with("#{url}: #{error_message}")

        request.instance_variable_set(:@tmp_file, file)
        request.send(:on_complete_cb, response)
      end
    end
  end
end
