require 'assert'
require 'tweetme/runner'

require 'tweetme/logger'

class Tweetme::Runner

  class UnitTests < Assert::Context
    desc "a sync runner"
    before do
      @username = ENV['TWEETME_USER']
      @custom_logger = Tweetme::UserLogger.new(@username)
      @runner = Tweetme::Runner.new(@username, {
        :interval => 20,
        :logger => @custom_logger
      })
    end
    subject { @runner }

    should have_readers :username, :interval, :logger
    should have_instance_methods :start, :stop, :shutdown?

    should "know its username" do
      assert_equal @username, subject.username
    end

    should "know its interval seconds" do
      assert_equal 20, subject.interval
    end

    should "default its interval to -1" do
      assert_equal -1, Tweetme::Runner.new(@username).interval
    end

    should "know its logger" do
      assert_equal @custom_logger, subject.logger
    end

    should "default its logger to a `UserLogger` for its username" do
      default_logger = Tweetme::Runner.new(@username).logger
      assert_kind_of Tweetme::Logger, default_logger
      assert_equal @username, default_logger.log_type
    end

  end

end
