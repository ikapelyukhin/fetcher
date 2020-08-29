require 'fetcher/request'
require 'uri'

module Fetcher
  def self.fetch(urls, logger = nil)
    hydra = Typhoeus::Hydra.new
    logger = logger || Logger.new(STDOUT)

    urls.each do |url|
      request = Fetcher::Request.new(logger, url, followlocation: true)
      hydra.queue(request)
    end

    hydra.run
  end
end