class Telegram::Poller
  include Enumerable

  def initialize
    @offset = 0
    @client = Telegram::Client.instance
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
    @client.silent do
      @client.get "getUpdates", offset: @offset, timeout: 60, limit: 100
    end
  rescue Errno::EHOSTUNREACH => e
    raise e
  rescue StandardError => e
    Console.warn self, "Error in the process of receiving updates:", e
    []
  end
end
