require 'simplecov'
SimpleCov.start { add_filter "/spec/" }

require 'fetcher'
require 'vcr'
require 'uri'

# Guess who patched VCR to work with Typhoeus and Farday? :-)
# * https://github.com/vcr/vcr/pull/656
# * https://github.com/vcr/vcr/pull/657

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures'
  c.hook_into :typhoeus
  c.configure_rspec_metadata!
end

RSpec.describe Fetcher do
  describe '.fetch' do
    let(:target_dir) { Dir.mktmpdir }
    let(:downloaded_files) do
      urls.map { |u| File.join(target_dir, URI(u).host, URI(u).path) }
    end
    let(:logger) { Logger.new('/dev/null') }

    after do
      FileUtils.rm_rf(target_dir)
    end

    context 'when multiple files are successfully downloaded', vcr: 'success' do
      let(:urls) do
        %w[
        https://i.imgur.com/4MDUmlx.png
        https://i.imgur.com/OosfKTg.png
        https://i.imgur.com/zJDFlD9.jpg
      ]
      end

      it 'files are downloaded' do
        described_class.fetch(urls, target_dir, logger)
        downloaded_files.each do |path|
          expect(File.exist?(path)).to be(true)
        end
      end

      it 'downloaded files have non-zero size' do
        described_class.fetch(urls, target_dir, logger)
        downloaded_files.each do |path|
          expect(File.size(path)).to satisfy("be greater than 0") { |size| size > 0 }
        end
      end

      it 'outputs success messages' do
        urls.each do |url|
          expect(logger).to receive(:info).with("#{url} -- saved.")
        end

        described_class.fetch(urls, target_dir, logger)
      end
    end

    context 'when errors are encountered during download', vcr: 'errors' do
      let(:urls) do
        %w[
          https://httpbin.org/status/404
          https://httpbin.org/status/403
          https://httpbin.org/status/500
        ]
      end

      it 'target directory is empty' do
        described_class.fetch(urls, target_dir, logger)

        expect(Dir.entries(target_dir)).to eq(%w[. ..])
      end

      it 'outputs error messages' do
        urls.each do |url|
          expect(logger).to receive(:error).with(%r{#{url}: request failed with code})
        end

        described_class.fetch(urls, target_dir, logger)
      end
    end

    context 'when input URLs have no file names' do
      let(:urls) do
        %w[
          https://example.org
          https://example.com
        ]
      end

      it 'target directory is empty' do
        described_class.fetch(urls, target_dir, logger)

        expect(Dir.entries(target_dir)).to eq(%w[. ..])
      end

      it 'outputs error messages' do
        urls.each do |url|
          expect(logger).to receive(:error).with("#{url}: No file name in the URL")
        end

        described_class.fetch(urls, target_dir, logger)
      end
    end
  end
end