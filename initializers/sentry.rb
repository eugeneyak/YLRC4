require "sentry-ruby"

Sentry.init do |config|
  config.dsn = Config::Sentry::DSN
  config.environment = Config::DEV ? "development" : "production"
  config.enable_logs = true
  config.traces_sample_rate = 1.0
  config.background_worker_threads = Config::DEV ? 0 : 1
end
