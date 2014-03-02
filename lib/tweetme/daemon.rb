require 'tweetme/tweet'
require 'tweetme/user'

users = Tweetme::User.all(ENV['TWEETME_USERS'])

while(true) do
  sleep 1
end
