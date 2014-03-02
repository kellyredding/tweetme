require 'tweetme'

Tweetme.run(ENV['TWEETME_USER'], :interval => ENV['TWEETME_INTERVAL'].to_i)
