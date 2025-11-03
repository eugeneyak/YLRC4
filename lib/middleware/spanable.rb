require "logger"

class Middleware::Spanable < Interactor::Middleware
  def call
    span = spawn_span

    receiver.instance_variable_set(:@__sentry_span__, span)

    logger.info "Interactor #{receiver.class} guarded"

    app.()
  ensure
    span.finish
  end

  def logger
    @logger ||= Logger.new($stdout)
  end

  def spawn_span
    parent_scope =
      if stack.root?
        Sentry.get_current_scope.get_span
      elsif stack.parent.instance_variable_get(:@__sentry_span__).nil?
        Sentry.get_current_scope.get_span
      else
        stack.parent.instance_variable_get(:@__sentry_span__)
      end

    parent_scope.start_child(op: receiver.class)
  end
end
