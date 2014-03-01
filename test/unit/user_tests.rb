require 'assert'
require 'tweetme/user'

require 'assert/factory'

class Tweetme::User

  class UnitTests < Assert::Context
    desc "Tweetme::User"
    setup do
      @username = Assert::Factory.string
      @user = Tweetme::User.new(@username)
    end
    subject{ @user }

    should have_cmeths :config_root
    should have_readers :username
    should have_writers :current_tweet
    should have_imeths :trc_path, :current_tweet_path, :current_tweet, :save

    should "know its trc and curren tweet file names" do
      assert_equal '.trc', TRC_FILE_NAME
      assert_equal '.current-tweet', CURRENT_TWEET_FILE_NAME
    end

    should "be able to set the config root" do
      prev_root = subject.class.config_root
      assert_not_nil prev_root

      subject.class.config_root('path/to/root')
      assert_equal 'path/to/root', subject.class.config_root.to_s

      subject.class.config_root(prev_root)
    end

    should "know its username" do
      assert_equal @username, subject.username
    end

    should "build its paths from the config root and its user name" do
      exp_path = subject_config_path(TRC_FILE_NAME)
      assert_equal exp_path, subject.trc_path

      exp_path = subject_config_path(CURRENT_TWEET_FILE_NAME)
      assert_equal exp_path, subject.current_tweet_path
    end

    should "default the current tweet" do
      assert_equal '', subject.current_tweet
    end

    protected

    def subject_config_path(file_name)
      subject.class.config_root.join("#{subject.username}/#{file_name}")
    end

  end

  class ValidUserTests < UnitTests
    desc "that has valid, non-empty configs"
    setup do
      @user = Tweetme::User.new('valid')
    end

    should "have an existing trc path" do
      assert_true subject.trc_path.exist?
    end

    should "default the current tweet from the current tweet config file" do
      assert_not_empty subject.current_tweet
      exp_tweet = subject_config_path(CURRENT_TWEET_FILE_NAME).read.strip
      assert_equal exp_tweet, subject.current_tweet
    end

  end

  class InvalidUserTests < UnitTests
    desc "that has involid configs"
    setup do
      @user = Tweetme::User.new('invalid')
    end

    should "have a non-existing trc path" do
      assert_false subject.trc_path.exist?
    end

    should "default the current tweet to an empty string" do
      assert_equal '', subject.current_tweet
    end

  end

  class EmptyUserTests < UnitTests
    desc "that has empty configs"
    setup do
      @user = Tweetme::User.new('empty')
    end

    should "have an existing trc path" do
      assert_true subject.trc_path.exist?
    end

    should "default the current tweet to an empty string" do
      assert_equal '', subject.current_tweet
    end

  end

  class SaveTests < UnitTests
    desc "when saving"
    setup do
      @user = Tweetme::User.new('valid')
      @prev_curr_tweet = @user.current_tweet
      @new_tweet = Assert::Factory.integer.to_s
    end

    should "write the current tweet" do
      subject.current_tweet = @new_tweet
      assert_equal @prev_curr_tweet, file_tweet

      subject.save
      assert_equal @new_tweet, file_tweet

      subject.current_tweet = @prev_curr_tweet
      subject.save
      assert_equal @prev_curr_tweet, file_tweet
    end

    def file_tweet
      subject_config_path(CURRENT_TWEET_FILE_NAME).read.strip
    end

  end

end
