require "logger"

class Middleware::Loggable < Yaks::Interactor::Middleware
  def call
    logger.info "Interactor #{receiver.class} started"

    result = app.()

    logger.info "Interactor #{receiver.class} finished"

    result
  end

  private

  def logger
    @logger ||= Logger.new($stdout)
  end
end
