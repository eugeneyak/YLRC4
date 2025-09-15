module Config
  module Sentry
    DSN = ENV.fetch("SENTRY_DSN")
  end

  module Telegram
    TOKEN = ENV.fetch("TG_BOT_API_KEY")
  end

  GEMINI_API_KEY = ENV.fetch("GEMINI_API_KEY")
  CHANNEL        = ENV.fetch("CHANNEL").to_i

  DEV = ENV.fetch("DEV", false)
end
