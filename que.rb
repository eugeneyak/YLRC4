require "que"

require_relative "lib/config"
require_relative "loader"

loader = Loader.new(reload: Config::DEV)
loader.setup

Telegram::Bot.new(Config::Telegram::TOKEN)
