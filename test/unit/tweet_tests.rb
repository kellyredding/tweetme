require 'assert'
require 'tweetme/tweet'

require 'assert/factory'

class Tweetme::Tweet

  class UnitTests < Assert::Context
    desc "Tweetme::Tweet"
    setup do
      @data = {
        'status_id' => Assert::Factory.integer,
        'created_at' => Assert::Factory.datetime,
        'user' => Assert::Factory.string,
        'body' => Assert::Factory.text,
        'url' => Assert::Factory.dir_path
      }
      @tweet = Tweetme::Tweet.new(@data)
    end
    subject{ @tweet }

    should have_readers :status_id, :created_at, :user, :body, :url

    should "know its data values" do
      assert_equal @data['status_id'],   subject.status_id
      assert_equal @data['created_at'],  subject.created_at
      assert_equal @data['user'],        subject.user
      assert_equal @data['body'],        subject.body
      assert_equal @data['url'],         subject.url
    end

    should "default the data values" do
      tweet = Tweetme::Tweet.new

      assert_nil tweet.status_id
      assert_nil tweet.created_at
      assert_nil tweet.user
      assert_nil tweet.body
      assert_nil tweet.url
    end

  end

end
