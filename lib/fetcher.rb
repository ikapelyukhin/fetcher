require 'fetcher/request'
require 'uri'

module Fetcher
  def self.fetch(urls:, target_dir:, logger: nil, max_concurrency: 10)
    hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
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
