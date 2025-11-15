require "bundler/setup"

require "async"
require "async/barrier"
require "yaks/interactor"

require_relative "lib/config"
require_relative "loader"

loader = Loader.new(reload: Config::DEV)
loader.setup

Sync do |task|
  %w[INT TERM].each { |signal| trap(signal) { task.stop } }

  ssl_context = OpenSSL::SSL::SSLContext.new
  ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE if Config::DEV

  bot = Telegram::Bot.new(Config::Telegram::TOKEN, ssl_context: ssl_context)

  Console.info "Started as #{bot.me[:id]} #{bot.me[:username]}"

  bot.updates.each do |update|
    loader.reload!

    Entry.new(update).call
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
