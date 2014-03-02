require 'pathname'

module Tweetme

  class User

    TRC_FILE_NAME = '.trc'
    CURRENT_TWEET_FILE_NAME = '.current-tweet'

    def self.config_root(value = nil)
      @config_root = Pathname.new(value) if value
      @config_root
    end

    def self.all(usernames)
      usernames.split(',').map{ |username| self.new(username) }
    end

    attr_reader :username
    attr_writer :current_tweet

    def initialize(username)
      @username = username
    end

    def trc_path
      @trc_path ||= get_config_path(@username, TRC_FILE_NAME)
    end

    def current_tweet_path
      @current_tweet_path ||= get_config_path(@username, CURRENT_TWEET_FILE_NAME)
    end

    def current_tweet
      @current_tweet ||= get_current_tweet(self.current_tweet_path)
    end

    def save
      save_current_tweet(self.current_tweet_path, self.current_tweet)
    end

    private

    def get_config_path(username, file)
      self.class.config_root.join("#{username}/#{file}")
    end

    def get_current_tweet(config_path)
      config_path.exist? ? config_path.read.strip : ''
    end

    def save_current_tweet(config_path, current_tweet)
      config_path.write(current_tweet)
    end

  end

end
