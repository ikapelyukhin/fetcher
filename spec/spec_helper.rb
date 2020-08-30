require 'simplecov'
SimpleCov.start { add_filter "/spec/" }

if ENV['TRAVIS']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end