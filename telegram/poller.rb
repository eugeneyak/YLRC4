class Telegram::Poller
  include Enumerable

  def initialize
    @offset = 0
  end

  def each
    loop do
      Async::Task.current.annotate "Updates receiving (offset: #{@offset})"

      updates.each do |update|
        Console.info self, **update

        yield update

        @offset = update[:update_id] + 1
      end
    end
  end

  private

  def updates
    client.silent { client.get "getUpdates", offset: @offset, timeout: 60, limit: 100 }
  end

  def client
    @client ||= Telegram::Client.instance
  end
end
