require 'assert'
require 'tweetme/tcmd'

require 'scmd'
require 'tweetme/logger'
require 'tweetme/user'

class Tweetme::Tcmd

  class UnitTests < Assert::Context
    desc "Tweetme::Tcmd"
    setup do
      @user = Tweetme::User.new(ENV['TWEETME_USER'])
      @tcmd = Tweetme::Tcmd.new(@user)
    end
    subject{ @tcmd }

    should have_readers :user, :cmd_str, :logger, :timeout

    should "no the cmd string template to use" do
      exp = 't timeline --decode-uris --long --color never'
      assert_equal exp, Tweetme::Tcmd::CMD
    end

    should "know its user" do
      assert_equal @user, subject.user
    end

    should "know its cmd string" do
      exp = "#{Tweetme::Tcmd::CMD} --profile=#{subject.user.trc_path}"
      assert_equal exp, subject.cmd_str
    end

    should "default its logger to a null logger" do
      assert_kind_of Tweetme::Logger, subject.logger
      assert_equal 'null', subject.logger.log_type
    end

    should "default its timeout to the `TWEETME_TCMD_TIMEOUT` env var" do
      assert_equal ENV['TWEETME_TCMD_TIMEOUT'].to_i, subject.timeout
    end

    should "allow specifying custom logger and timeout values" do
      cust = Tweetme::Tcmd.new(@user, {
        :logger => @user.logger,
        :timeout => '1'
      })
      assert_equal @user.logger, cust.logger
      assert_equal 1, cust.timeout
    end

  end

  class RunTests < UnitTests
    desc "when run"
    setup do
      @orig_test_mode = ENV['TWEETME_TCMD_TEST_MODE']
      ENV['TWEETME_TCMD_TEST_MODE'] = nil
      @bin_root = Pathname.new("#{ENV['TWEETME_ROOT']}/test/support/bin")
    end
    teardown do
      ENV['TWEETME_TCMD_TEST_MODE'] = @orig_test_mode
    end

  end

  class SuccessTests < RunTests
    desc "and successful"
    setup do
      @tcmd.stubs(:cmd_str).returns(@bin_root.join('tcmd_success').to_s)
    end

    should "call a given command and return its data with the #call meth" do
      result = subject.run
      assert_equal "success!\n", result
    end

  end

  class FailTests < RunTests
    desc "and failing"
    setup do
      @tcmd.stubs(:cmd_str).returns(@bin_root.join('tcmd_fail').to_s)
    end

    should "raise a CmdError with the stderr value in the message" do
      e = nil
      begin
        subject.run
      rescue CmdError => e
      end

      assert_not_nil e
      assert_includes "fail!", e.message
    end

  end

  class TimeoutTests < RunTests
    desc "that times out running a cmd"
    setup do
      @tcmd.stubs(:cmd_str).returns(@bin_root.join('tcmd_success').to_s)
      @tcmd.stubs(:timeout).returns(0.1)
    end

    should "raise a TimeoutError with the timeout value in the message" do
      e = nil
      begin
        subject.run
      rescue TimeoutError => e
      end
      assert_not_nil e

      assert_includes subject.timeout.to_s, e.message
    end

  end

  class CmdErrorTests < RunTests
    desc "cmd error"
    setup do
      @cmd = Scmd::Command.new(@bin_root.join('tcmd_fail').to_s).run
      @err = CmdError.new(@cmd, 'err msg')
    end
    subject{ @err }

    should have_readers :cmd

    should "be a runtime error" do
      assert_kind_of RuntimeError, subject
    end

    should "know its cmd" do
      assert_equal @cmd, subject.cmd
    end

    should "include the error message in its message" do
      assert_includes 'err msg', subject.message
    end

    should "include the cmd details in its message" do
      e = subject
      assert_includes ", cmd output: `\"fail!\\n\"`", e.message
      assert_match    /, cmd: .+test\/support\/bin\/tcmd_fail/, e.message
      assert_includes ", exitstatus: 1", e.message
      assert_includes ", stdout: \"\"", e.message
      assert_includes ", stderr: \"fail!\\n\"", e.message
    end

  end

end
