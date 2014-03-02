require 'thread'
require 'tweetme/logger'
require 'tweetme/user'

module Tweetme

  class Runner

    attr_reader :username, :interval, :logger

    def initialize(username, opts = nil)
      opts ||= {}
      @username = username
      @interval = opts[:interval].kind_of?(Fixnum) ? opts[:interval] : -1
      @logger = opts[:logger] || Tweetme::UserLogger.new(@username)
      @shutdown = false
      @user_run_thread = nil

      Signal.trap('SIGINT',  proc{ raise Interrupt, 'SIGINT'  })
      Signal.trap('SIGQUIT', proc{ raise Interrupt, 'SIGQUIT' })
      Signal.trap('TERM',    proc{ raise Interrupt, 'TERM'    })
    end

    def start
      startup!
      loop do
        loop_run
        break if shutdown?
      end
      shutdown!
    end

    def stop
      if @shutdown != true
        main_log "Stop signal - waiting for any user runs to finish."
        @shutdown = true
      end
    end

    def shutdown?
      !!@shutdown
    end

    protected

    def startup!
      main_log "Starting up the runner."
      if @interval < 0
        main_log "run-once interval - signaling stop"
        stop
        @interval = 0
      end
    end

    def shutdown!
      main_log "Shutting down the runner"
    end

    def loop_run
      begin
        main_log "Starting user run in fresh thread."
        @user_run_thread = Thread.new { user_run_thread }

        if @interval > 0
          main_log "Sleeping for #{@interval} second interval."
          sleep(@interval)
          main_log "Woke from sleep"
        end
      rescue Interrupt => e
        stop
      ensure
        join_user_run_thread
      end
    end

    def join_user_run_thread
      begin
        if @user_run_thread
          main_log "Waiting for user run thread to join..."
          @user_run_thread.join
          main_log "... user run thread has joined."
        end
        @user_run_thread = nil
      rescue Interrupt => e
        stop
        join_user_run_thread
      end
    end

    def user_run_thread
      thread_log "start #{@username.inspect} user run..."

      begin
        # TODO: user run obj
        do_user_run(@username) if !self.shutdown?
        GC.start
      rescue StandardError => e
        thread_log_error(e, :error)
      end

      thread_log "... end #{@username.inspect} user run"
    end

    def do_user_run(user_run)
      begin
        sleep 1 # TODO: do user run
      rescue StandardError => e
        handle_user_run_error(user_run, e)
      end
    end

    def handle_user_run_error(user_run, err)
      thread_log_error(err)
      # TODO: notify of an error in a run?
    end

    def thread_log_error(err, level = :warn)
      thread_log "#{err.message} (#{err.class.name})", level
      err.backtrace.each { |bt| thread_log bt.to_s, level }
    end

    def main_log(msg, level = :info)
      log "[MAIN]: #{msg}", level
    end

    def thread_log(msg, level = :info)
      log "[THREAD]: #{msg}", level
    end

    def log(msg, level)
      @logger.send(level, msg)
    end

  end

end
