require 'logsly'

Logsly.colors('tweetme_stdout') do
  debug :magenta
  info  :cyan
  warn  :yellow
  error :red
  fatal [:white, :on_red]

  date    :blue
  message :white
end

Logsly.stdout('tweetme_stdout') do |logger|
  colors  'tweetme_stdout'
  pattern '%m\n'
end

Logsly.file('tweetme_file') do |logger|
  path File.join(ENV['TWEETME_LOGGER_ROOT'], "#{ENV['TWEETME_ENV']}-#{logger.log_type}.log")

  # no colors
  # just show msg in dev logs; show date,level,msg in non dev logs
  pattern ENV['TWEETME_ENV'] == 'development' ? '%m\n' : '[%d %-5l] : %m\n'
end

module Tweetme

  module NullLogger
    def self.new(*args)
      Tweetme::Logger.new('null', :outputs => [])
    end
  end

  module UserLogger
    def self.new(username, opts = nil)
      Tweetme::Logger.new(username, opts || {})
    end
  end

  class Logger
    include Logsly

    def initialize(log_type, opts = nil)
      opts ||= {}
      opts[:outputs] ||= default_outputs
      opts[:level]   ||= default_level

      super(log_type, opts)
    end

    protected

    def default_level
      ENV['TWEETME_ENV'] == 'production' ? 'info' : 'debug'
    end

    def default_outputs
      [ 'tweetme_file' ].tap do |o|
        o << 'tweetme_stdout' if ENV['TWEETME_ENV'] == 'development'
      end
    end

  end

end
