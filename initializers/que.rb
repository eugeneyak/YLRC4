require "que"

require_relative "sequel"

Que.connection = DB

Que.job_middleware.push(
  lambda do |job, &block|
    opts = {
      op: job.que_attrs[:job_class],
      description: job.que_attrs[:job_class],
      trace_id: job.que_attrs.dig(:kwargs, :trace_id)
    }

    transaction = Sentry.start_transaction(**opts.compact)
    Sentry.get_current_scope.set_span(transaction) if Sentry.get_current_scope

    block.call

  rescue StandardError => e
    Sentry.capture_exception(e)
    raise

  ensure
    transaction.finish if transaction
  end
)

Que::Job.run_synchronously = true if Config::DEV
