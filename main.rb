require "sentry-ruby"

require "async"
require "async/barrier"
require "async/semaphore"

require "sequel"
require "sequel/adapters/postgres"

require_relative "config"
require_relative "telegram"
require_relative "fsa"

require_relative "ai"

require_relative "workers/start"
require_relative "workers/start/init"

require_relative "workers/service"
require_relative "workers/service/init"
require_relative "workers/service/photo_await"
require_relative "workers/service/photos_await"

Sequel.extension :migration

DB = Sequel.postgres(
  database: Config::DB::DATABASE,
  host: Config::DB::HOST,
  port: Config::DB::PORT,
  user: Config::DB::USER,
  password: Config::DB::PASSWORD
)

DB.extension :pg_json

Console.logger.debug! if Config::DEV

Sentry.init do |config|
  config.dsn = Config::Sentry::DSN
  config.environment = Config::DEV ? "development" : "production"
  config.enable_logs = true
  config.traces_sample_rate = 1.0
  config.background_worker_threads = Config::DEV ? 0 : 1
end

Sequel::Migrator.run(DB, "migrations", use_transactions: true)

Sync do |task|
  %w[INT TERM].each do |signal|
    trap(signal) { task.stop }
  end

  bot = Telegram::Bot.new(Config::Telegram::TOKEN)

  # Console.info "Started as #{bot.me[:id]} #{bot.me[:username]}"

  switchman = FSA::Switchman.new

  switchman.register(start: Start)
  switchman.register(service: Service)

  bot.updates.each do |update|
    update => update_id: update_id

    DB.from(:updates).insert_conflict.insert(
      update_id: update_id,
      created_at: Sequel.function(:now),
      payload: Sequel.pg_jsonb_wrap(update),
    )

    switchman << update
  rescue StandardError => e
    update => message: { from: from }

    barrier = Async::Barrier.new

    barrier.async do
      Console.error(e, e.message, *e.backtrace)
    end

    barrier.async do
      Sentry.set_user(id: from[:id], username: from[:username], name: "#{from[:first_name]} #{from[:last_name]}".strip)
      Sentry.capture_exception(e)
    end

    barrier.async do
      Telegram::Client.instance.post "sendMessage",
        chat_id: from[:id],
        text: "Тут какая-то ошибка, это не твоя вина, но твоя проблема. Мы починим, но это не точно"
    end

    barrier.wait
  end
end
