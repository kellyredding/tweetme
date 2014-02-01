# this file is automatically required when you run `assert`
# put any test helpers here

require 'pry' # require pry for debugging (`binding.pry`)
require 'assert-mocha' if defined?(Assert)

require File.expand_path('../../config/init', __FILE__)
