require "bundler/setup"

require "que"
require "yaks/interactor"

require_relative "lib/config"
require_relative "loader"

loader = Loader.new(reload: Config::DEV)
loader.setup

Sync do
  bot = Telegram::Bot.new(Config::Telegram::TOKEN)

  Console.info "Started as #{bot.me[:id]} #{bot.me[:username]}"
end
