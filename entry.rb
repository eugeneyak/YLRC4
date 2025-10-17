class Entry
  extend Interactor

  use Loggable

  def initialize(update)
    @update = update
  end

  attr_reader :update

  def call
    transaction = start_transaction

    update => update_id: update_id

    Sentry.configure_scope do |scope|
      scope.set_context("update", update)
      scope.set_tag("update_id", update_id)
    end

    Switchman.new(update).call
  ensure
    transaction.finish if transaction
  end

  def start_transaction
    transaction =
      case update
      in update_id: update_id, message: { text: text } if text.start_with? "/"
        Sentry.start_transaction(op: text, description: "Update #{update_id}")

      in update_id: update_id, message: { from: user } if dialogue = dialogue_with(user)
        Sentry.start_transaction(description: "Update #{update_id}", trace_id: @dialogue[:trace_id])

      in update_id: update_id
        Sentry.start_transaction(description: "Update #{update_id}")
      end

    Sentry.get_current_scope.set_span(transaction) if Sentry.get_current_scope

    transaction
  end

  def dialogue_with(user)
    @dialogue ||= DB.from(:dialogues).first(user_id: user[:id])
  end
end
