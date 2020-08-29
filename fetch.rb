#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(__dir__, 'lib')

require 'fetcher'

# FIXME argparser

urls = %w[
https://example.org/
http://somewebsrv.com/img/992147.jpg
]

Fetcher.fetch(urls)