require 'tweetme/runner'

module Tweetme

  def self.run(*args)
    Runner.new(*args).start
  end

end
