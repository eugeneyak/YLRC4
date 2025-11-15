class Telegram::Bot
  include Telegram::API

  def initialize(...)
    Telegram::Client.instance = Telegram::Client.new(...)
  end

  def updates
    Telegram::Poller.new
  end

  private

  def client = Telegram::Client.instance
end
