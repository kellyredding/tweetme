require 'tweetme/logger'
require 'tweetme/tweet'
require 'tweetme/user'

logger = Tweetme::UserLogger.new(ENV['TWEETME_USER'])
logger.info "Starting daemon"
user = Tweetme::User.new(ENV['TWEETME_USER'])
logger.info "Tweetme User: #{user.inspect}"

while(true) do
  sleep 1
end
