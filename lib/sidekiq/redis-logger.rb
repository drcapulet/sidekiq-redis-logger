require "sidekiq/web"
require "sidekiq/redis-logger/logger"
require "sidekiq/redis-logger/middleware"
require "sidekiq/redis-logger/version"
require "sidekiq/redis-logger/web_extension"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.insert_before Sidekiq::Middleware::Server::Logging, Sidekiq::RedisLogger::Middleware
  end
  config.logger = Sidekiq::RedisLogger::Logger.new(Sidekiq::Logging.logger)
end

if Sidekiq::Web.tabs.is_a?(Array)
  # For sidekiq < 2.5
  Sidekiq::Web.tabs << "logs"
else
  Sidekiq::Web.tabs["Logs"] = "logs"
end
Sidekiq::Web.register Sidekiq::RedisLogger::WebExtension
