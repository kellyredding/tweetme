require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'dotenv'
Dotenv.load

# add load paths
root = Pathname.new(File.expand_path('../..', __FILE__))
$LOAD_PATH.push root
$LOAD_PATH.push root.join('app/models')
$LOAD_PATH.push root.join('lib')
