require 'fetcher/request'
require 'uri'

module Fetcher
  def self.fetch(urls, target_dir, logger = nil)
    hydra = Typhoeus::Hydra.new
    logger = logger || Logger.new(STDOUT)

    urls.each do |url|
      begin
        request = Fetcher::Request.new(logger, target_dir, url, followlocation: true)
        hydra.queue(request)
      rescue Fetcher::Exception => e
        logger.error("%s: %s" % [url, e])
      end
    end

    hydra.run
  end
end
