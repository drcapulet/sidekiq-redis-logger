module Sidekiq
  module RedisLogger
    module WebExtension
      def self.registered(app)
        app.helpers do
          def find_template(view, *a, &b)
            dir = File.expand_path("../views/", __FILE__)
            super(dir, *a, &b)
            super
          end
        end
        
        app.get "/logs" do
          slim :logs
        end
      
        app.get "/logs/poll" do
          Sidekiq.redis do |conn|
            if params[:jid]
              conn.exists("logger:#{params[:jid]}") ? conn.lrange("logger:#{jid}", 0, -1).reverse.join : "No log"
            else
              conn.lrange("logger", 0, -1).reverse.join("\n")
            end
          end
        end
      end
    end
  end
end