require 'typhoeus'
require 'fetcher'

module Fetcher
  class Request < Typhoeus::Request
    def initialize(logger, url, *args)

      # FIXME file basename handling
      # FIXME target dir

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
      @tmp_file ||= create_tmp_file
      @tmp_file.write(chunk)
    rescue StandardError => e
      return :abort
    end

    def on_complete_cb(response = nil)
      @tmp_file.close if @tmp_file

      # FIXME rename the tmp file

      if response.success?
        @logger.info("#{url} -- saved.")
      else
        if response.code == 0 || response.return_code != :ok
          @logger.error("%s: %s" % [ url, response.return_message ])
        else
          @logger.error("%s: request failed with code %s" % [ url, response.code.to_s ])
        end
      end
    ensure
      cleanup_temp_file
    end

  end
end