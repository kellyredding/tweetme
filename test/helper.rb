# this file is automatically required when you run `assert`
# put any test helpers here

ENV['TWEETME_ENV'] = 'test'

require 'pry' # require pry for debugging (`binding.pry`)
require 'assert-mocha' if defined?(Assert)

require File.expand_path('../../config/init', __FILE__)

require 'tweetme/user'
Tweetme::User.config_root(File.expand_path('../support/users', __FILE__))
