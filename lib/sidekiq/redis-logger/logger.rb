require 'logger'

module Sidekiq
  module RedisLogger
    class Logger
      include ::Logger::Severity

      class Pretty < ::Logger::Formatter
        # Provide a call() method that returns the formatted message.
        def call(severity, time, program_name, message)
          "#{time.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{context} #{severity}: #{message}\n"
        end

        def context
          c = Thread.current[:sidekiq_context]
          c ? " #{c}" : ''
        end
      end

      def self.with_jid_context(jid)
        begin
          Thread.current[:sidekiq_jid] = jid
          yield
        ensure
          Thread.current[:sidekiq_jid] = nil
        end
      end

      # alt is an extra output
      def initialize(alt = nil, limit = 10000)
        @formatter = Pretty.new
        @alt = alt
        @limit = limit
        @level = INFO
      end

      def add(severity, message = nil, progname = nil, &block)
        severity ||= UNKNOWN
        return true if severity < @level
        if message.nil?
          if block_given?
            message = yield
          else          
            message = progname
            progname = nil
          end
        end
        msg = format_message(format_severity(severity), Time.now, progname, message)
        if Sidekiq.instance_variable_get(:@redis)
          Sidekiq.redis do |conn|
            jid = Thread.current[:sidekiq_jid]
            conn.lpush("logger:#{jid}", msg) if jid
            conn.expire("logger:#{jid}", 20 * 60) if jid
            conn.lpush("logger", msg)
            conn.ltrim("logger", 0, @limit - 1)
          end
        end
        @alt.add(severity, message, progname) if @alt
        return true
      end
      alias log add

      def <<(msg)
        if Sidekiq.instance_variable_get(:@redis)
          Sidekiq.redis do |conn|
            jid = Thread.current[:sidekiq_jid]
            conn.lpush("logger:#{jid}", msg) if jid
            conn.expire("logger:#{jid}", 20 * 60) if jid
            conn.lpush("logger", msg)
            conn.ltrim("logger", 0, @limit - 1)
          end
        end
        @alt << msg if @alt
      end

      def debug(progname = nil, &block)
        add(DEBUG, nil, progname, &block)
      end

      def info(progname = nil, &block)
        add(INFO, nil, progname, &block)
      end

      def warn(progname = nil, &block)
        add(WARN, nil, progname, &block)
      end

      def error(progname = nil, &block)
        add(ERROR, nil, progname, &block)
      end

      def fatal(progname = nil, &block)
        add(FATAL, nil, progname, &block)
      end

      def unknown(progname = nil, &block)
        add(UNKNOWN, nil, progname, &block)
      end

      def close
        return true
      end

      private
        SEV_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY)
        def format_severity(severity)
          SEV_LABEL[severity] || 'ANY'
        end
  
        def format_message(severity, datetime, progname, msg)
          @formatter.call(severity, datetime, progname, msg)
        end
    end
  end
end