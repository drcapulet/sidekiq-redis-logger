# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/redis-logger/version"

Gem::Specification.new do |gem|
  gem.name          = "sidekiq-redis-logger"
  gem.version       = Sidekiq::RedisLogger::VERSION
  gem.authors       = ["Alex Coomans"]
  gem.email         = ["alex@alexcoomans.com"]
  gem.description   = %q{Direct Sidekiq logs into Redis as well}
  gem.summary       = %q{Direct Sidekiq logs into Redis as well and provide a web UI tab for watching}
  gem.homepage      = "https://github.com/drcapulet/sidekiq-redis-logger"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "sidekiq", ">= 2.6.0"
  gem.add_dependency "slim"
  gem.add_dependency "sinatra"
end
