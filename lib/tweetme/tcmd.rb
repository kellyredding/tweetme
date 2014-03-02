require 'benchmark'
require 'scmd'
require 'tweetme/logger'

module Tweetme

  class Tcmd

    class CmdRunError < RuntimeError; end

    CMD = 't timeline --decode-uris --long --color never'

    attr_reader :user, :cmd_str, :logger, :timeout

    def initialize(*args)
      opts, @user = [
        args.last.kind_of?(Hash) ? args.pop : {},
        args.last
      ]
      @cmd_str = "#{CMD} --profile=#{@user.trc_path}"
      @logger = opts[:logger] || NullLogger.new
      @timeout = (opts[:timeout] || ENV['TWEETME_TCMD_TIMEOUT']).to_i
      @result = opts[:result]
    end

    def run
      return @result if ENV['TWEETME_TCMD_TEST_MODE']
      cmd_result = nil
      cmd = Scmd::Command.new(self.cmd_str)
      benchmark = Benchmark.measure do
        cmd_result = run!(cmd, self.timeout)
      end
      summary_line = SummaryLine.new({
        'time' => RoundedTime.new(benchmark.real),
        'pid' => cmd.pid,
        'exitstatus' => cmd.exitstatus,
        'cmd' => cmd.to_s
      })
      self.logger.info("[TCMD] #{summary_line}")

      raise CmdError.new(cmd, cmd.stderr) if !cmd.success?
      cmd_result
    end

    private

    def run!(cmd, timeout)
      begin
        cmd.start
        cmd.wait(timeout)
      rescue Scmd::TimeoutError
        cmd.stop
        msg = "Time out (#{timeout}s) calling the tcmd `#{cmd}`"
        raise TimeoutError.new(cmd, msg)
      end
      cmd.stdout
    end

    module SummaryLine
      def self.new(line_attrs)
        attr_keys = ['time', 'pid', 'exitstatus', 'cmd' ]
        attr_keys.map{ |k| "#{k}=#{line_attrs[k].inspect}" }.join(' ')
      end
    end

    module RoundedTime
      ROUND_PRECISION = 2
      ROUND_MODIFIER = 10 ** ROUND_PRECISION
      def self.new(time_in_seconds)
        (time_in_seconds * 1000 * ROUND_MODIFIER).to_i / ROUND_MODIFIER.to_f
      end
    end

    class CmdError < RuntimeError
      attr_reader :cmd

      def initialize(cmd, msg = nil)
        @cmd = cmd
        cmd_output = "`#{(@cmd.success? ? cmd.stdout : cmd.stderr).inspect}`"

        err_msg = msg || 'unknown cmd error'
        err_msg += ", cmd output: #{cmd_output}"\
                   ", cmd: #{@cmd.to_s.inspect}"\
                   ", exitstatus: #{@cmd.exitstatus.inspect}"\
                   ", stdout: #{@cmd.stdout.inspect}"\
                   ", stderr: #{@cmd.stderr.inspect}"
        super(err_msg)
      end
    end

    TimeoutError = Class.new(CmdError)

  end

end
