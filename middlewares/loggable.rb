require "logger"

class Loggable < Interactor::Middleware
  def call
    logger.info "Interactor #{receiver.class} started"
    # Sentry.logger.info("Interactor #{receiver.class} started", interactor: receiver.class)

    result = app.()

    logger.info "Interactor #{receiver.class} finished"

    result
  end

  private

  def logger
    @logger ||= Logger.new($stdout)
  end
end
