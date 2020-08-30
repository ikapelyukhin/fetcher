require 'typhoeus'
require 'fetcher'
require 'uri'

module Fetcher
  class Exception < StandardError; end

  class Request < Typhoeus::Request
    def initialize(logger, target_dir, url, *args)

      uri = URI(url)

      basename = File.basename(uri.path)
      raise Fetcher::Exception.new("No file name in the URL") if basename == "/" || basename.empty?

      @target_file = File.join(target_dir, uri.host, uri.path)

      super(url, *args)
      @logger = logger
      @on_complete = [ self.method(:on_complete_cb) ]
      @on_body = [ self.method(:on_body_cb) ]
    end

    protected

    def create_temp_file
      file = Tempfile.create('fetcher')
      file
    end

    def cleanup_temp_file
      return unless @tmp_file
      File.unlink(@tmp_file.path) if File.exist?(@tmp_file.path)
    end

    def on_body_cb(chunk, response)
      @tmp_file ||= create_temp_file
      @tmp_file.write(chunk)
    rescue StandardError => e
      return :abort
    end

    def on_complete_cb(response)
      @tmp_file.close if @tmp_file

      if response.success?
        dirname = File.dirname(@target_file)
        FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
        FileUtils.mv(@tmp_file.path, @target_file)

        @logger.info("#{url} -- saved.")
      else
        if response.code != 0
          @logger.error("%s: request failed with code %s" % [ url, response.code ])
        else
          @logger.error("%s: %s" % [ url, response.return_message ])
        end
      end
    rescue StandardError => e
      @logger.error("%s: %s" % [ url, e ])
    ensure
      cleanup_temp_file
    end

  end
end
