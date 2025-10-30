class Telegram::Bot
  include Telegram::API

  def initialize(token)
    Telegram::Client.instance = Telegram::Client.new(token)
  end

  def updates
    Telegram::Poller.new
  end

  private

  def client = Telegram::Client.instance
end
