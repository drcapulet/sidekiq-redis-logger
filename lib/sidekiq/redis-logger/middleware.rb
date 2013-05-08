module Sidekiq
  module RedisLogger
    class Middleware
      def call(worker, msg, queue)
        Sidekiq::RedisLogger::Logger.with_jid_context(msg["jid"]) do
          yield
        end
      end
    end
  end
end