require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

ENV['TWEETME_ENV'] ||= 'development'
ENV['TWEETME_INTERVAL'] ||= '20' # seconds
ENV['TWEETME_TCMD_TIMEOUT'] ||= '20' # seconds
ENV['TWEETME_TCMD_PAGE_SIZE'] ||= '5' # tweets

require 'dotenv'
Dotenv.load('.env', ".env.#{ENV['TWEETME_ENV']}")

# add load paths
root = Pathname.new(File.expand_path('../..', __FILE__))
ENV['TWEETME_ROOT'] = root.to_s
ENV['TWEETME_LOGGER_ROOT'] = root.join('log').to_s
$LOAD_PATH.push root
$LOAD_PATH.push root.join('lib')
