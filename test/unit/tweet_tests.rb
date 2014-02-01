require 'assert'
require 'tweetme/tweet'

class Tweetme::Tweet

  class UnitTests < Assert::Context
    desc "Tweetme::Tweet"
    setup do
      @tweet = Tweetme::Tweet.new
    end
    subject{ @tweet }

    should have_readers :status_id, :created_at, :user, :body, :url

  end

end
