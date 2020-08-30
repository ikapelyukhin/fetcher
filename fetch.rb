#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(__dir__, 'lib')

require 'fetcher'
require 'optparse'

options = {
    concurrency: 10,
    output_dir: "./"
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-i", "--input-file INPUT_FILE", "Path to a file with a list of URLs") do |v|
    options[:input_file] = v
  end
  opts.on("-o", "--output-dir OUTPUT_DIR", "Output directory (default: '#{options[:output_dir]}')") do |v|
    options[:output_dir] = v
  end
  opts.on(
      "-c", "--concurrency CONCURRENCY",
      "Number of maximum concurrent downloads (default: #{options[:concurrency]}"
  ) do |v|
    options[:concurrency] = v
  end
end
parser.parse!

unless options[:input_file]
  $stderr.puts  parser.help
  exit 1
end

urls = File.readlines(options[:input_file]).map(&:strip).uniq.reject(&:empty?)
Fetcher.fetch(urls: urls, target_dir: options[:output_dir], max_concurrency: options[:concurrency])
