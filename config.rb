module Config
  module DB
    DATABASE = ENV.fetch("DATABASE", "lrc4")
    HOST = ENV.fetch("DATABASE_HOST", "localhost")
    PORT = ENV.fetch("DATABASE_PORT", 5432).to_i
    USER = ENV.fetch("DATABASE_USER", nil)
    PASSWORD = ENV.fetch("DATABASE_PASSWORD", nil)
  end

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
