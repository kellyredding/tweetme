require File.expand_path('../setup', __FILE__)

require 'tweetme/user'
Tweetme::User.config_root(File.expand_path('../users', __FILE__))
