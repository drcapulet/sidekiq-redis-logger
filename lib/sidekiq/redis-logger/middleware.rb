module Sidekiq
  module RedisLogger
    class Middleware
      def call(worker, item, queue)
        Sidekiq::RedisLogger::Logger.with_jid_context(item["jid"]) do
          yield
        end
      end
    end
  end
end