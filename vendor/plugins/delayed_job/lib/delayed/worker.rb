require 'rush'

module Delayed
  class Worker
    SLEEP = 5

    cattr_accessor :logger
    self.logger = if defined?(Merb::Logger)
      Merb.logger
    elsif defined?(RAILS_DEFAULT_LOGGER)
      RAILS_DEFAULT_LOGGER
    end

    def initialize(options={})
      @quiet = options[:quiet]
      Delayed::Job.min_priority = options[:min_priority] if options.has_key?(:min_priority)
      Delayed::Job.max_priority = options[:max_priority] if options.has_key?(:max_priority)
    end

    def make_pid_file
      Dir.mkdir('tmp') unless File.exists?('tmp') && File.directory?('tmp')
      File.open('tmp/delayed_job.pid','w') do |f|
        f.puts "#{Process.pid}"
      end
    end

    def remove_pid_file
      File.delete('tmp/delayed_job.pid') if File.exist?('tmp/delayed_job.pid')
    end

    def start
      say "*** Starting job worker #{Delayed::Job.worker_name}"
      make_pid_file #pid file being made on start of scale up, this will be checked on each job enqueue
      trap('TERM') { say 'Exiting...'; $exit = true }
      trap('INT')  { say 'Exiting...'; $exit = true }

      loop do
        result = nil

        realtime = Benchmark.realtime do
          result = Delayed::Job.work_off
        end

        count = result.sum

        Manager.scale_down if count.zero? && Job.auto_scale && Job.count == 0

        break if $exit

        if count.zero?
          sleep(SLEEP)
        else
          say "#{count} jobs processed at %.4f j/s, %d failed ..." % [count / realtime, result.last]
        end

        break if $exit
      end

    ensure
      Delayed::Job.clear_locks!
      remove_pid_file
    end

    def say(text)
      puts text unless @quiet
      logger.info text if logger
    end

  end
end
