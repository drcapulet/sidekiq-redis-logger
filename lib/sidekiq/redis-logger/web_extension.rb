module Sidekiq
  module RedisLogger
    module WebExtension
      def self.registered(app)
        app.get "/logs" do
          view_path = File.expand_path("../views/", __FILE__)
          render(:slim, File.read(File.join(view_path, 'logs.slim')))
        end
      
        app.get "/logs/poll" do
          Sidekiq.redis do |conn|
            if params[:jid]
              conn.exists("logger:#{params[:jid]}") ? conn.lrange("logger:#{jid}", 0, 100).reverse.join : "No log"
            else
              conn.lrange("logger", 0, 100).reverse.join
            end
          end
        end
      end
    end
  end
end
