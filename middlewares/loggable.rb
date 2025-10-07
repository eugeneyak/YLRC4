require "logger"

class Loggable < Interactor::Middleware
  def call
    logger.info "#{receiver.class} kek"
    result = yield
    logger.info "#{receiver.class} lol"
    result
  end

  private

  def logger
    @logger ||= Logger.new($stdout)
  end
end
