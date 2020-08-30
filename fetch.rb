#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(__dir__, 'lib')

require 'fetcher'

# FIXME argparser

urls = %w[
https://i.imgur.com/4MDUmlx.png
https://i.imgur.com/OosfKTg.png
https://i.imgur.com/zJDFlD9.jpg
]

Fetcher.fetch(urls, './')
