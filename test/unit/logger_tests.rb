require 'assert'
require 'tweetme/logger'

require 'logsly'

class Tweetme::Logger

  class UnitTests < Assert::Context
    desc "Tweetme::Logger"
    setup do
      @prev_env = ENV['TWEETME_ENV']
      @logger = Tweetme::Logger.new('test')
    end
    teardown do
      ENV['TWEETME_ENV'] = @prev_env
      Logsly.reset
    end
    subject { @logger }

    should "know its log type" do
      assert_equal 'test', subject.log_type
    end

    should "default the level based on the environment" do
      ENV['TWEETME_ENV'] = 'production'
      assert_equal 'info', Tweetme::Logger.new('test').level

      ENV['TWEETME_ENV'] = 'whatever'
      assert_equal 'debug', Tweetme::Logger.new('test').level

    end

    should "default the outputs based on the environment" do
      ENV['TWEETME_ENV'] = 'development'
      assert_equal [ 'tweetme_file', 'tweetme_stdout' ], Tweetme::Logger.new('test').outputs

      ENV['TWEETME_ENV'] = 'whatever'
      assert_equal [ 'tweetme_file' ], Tweetme::Logger.new('test').outputs
    end

  end

  class NullLoggerTests < UnitTests
    desc "null logger"
    setup do
      @null_logger = Tweetme::NullLogger.new
    end
    subject{ @null_logger }

    should "be a Logger" do
      assert_kind_of Tweetme::Logger, subject
    end

    should "have 'null' as its log type" do
      assert_equal 'null', subject.log_type
    end

    should "have the same level as a normal logger" do
      assert_equal @logger.level,    subject.level
    end

    should "have no outputs" do
      assert_empty subject.outputs
    end

  end

  class MainLoggerTests < UnitTests
    desc "main logger"
    setup do
      @main_logger = Tweetme::MainLogger.new
    end
    subject { @main_logger }

    should "be a Logger" do
      assert_kind_of Tweetme::Logger, subject
    end

    should "have 'main' as its log type" do
      assert_equal 'main', subject.log_type
    end

    should "have the same level and outputs as a normal logger" do
      assert_equal @logger.level,   subject.level
      assert_equal @logger.outputs, subject.outputs
    end

  end

  class UserLoggerTests < UnitTests
    desc "user logger"
    setup do
      @user_logger = Tweetme::UserLogger.new('joe')
    end
    subject { @user_logger }

    should "be a Logger" do
      assert_kind_of Tweetme::Logger, subject
    end

    should "have the same level and outputs as a normal logger" do
      assert_equal @logger.level,   subject.level
      assert_equal @logger.outputs, subject.outputs
    end

    should "have ther username as the log_type" do
      assert_equal 'joe', subject.log_type
    end

  end

end
