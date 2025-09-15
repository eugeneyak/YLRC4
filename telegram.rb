module Telegram
  class Error < StandardError; end
  class UnauthorizedError < Error; end

  require_relative "telegram/client"
  require_relative "telegram/api"
  require_relative "telegram/bot"
  require_relative "telegram/poller"
end
