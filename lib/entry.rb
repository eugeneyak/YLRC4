class Entry
  extend Interactor

  use Middleware::Loggable

  def initialize(update)
    @update = update
  end

  attr_reader :update

  def call
    transaction = start_transaction

    update => update_id: update_id

    Sentry.configure_scope do |scope|
      scope.set_tag("update_id", update_id)
      scope.set_context("update", update)
    end

    Switchman.new(update).call
  ensure
    transaction.finish if transaction
  end

  def start_transaction
    transaction =
      case update
      in update_id: update_id, message: { text: text, from: from } if text.start_with? "/"
        DB.from(:users)
          .insert_conflict(
            target: :id,
            update: {
              first_name: Sequel[:excluded][:first_name],
              last_name: Sequel[:excluded][:last_name],
              username: Sequel[:excluded][:username],
              premium: Sequel[:excluded][:premium],
              bot: Sequel[:excluded][:bot],
              language_code: Sequel[:excluded][:language_code]
            }
          )
          .insert(
            id: from[:id],
            first_name: from[:first_name],
            last_name: from[:last_name],
            username: from[:username],
            premium: from[:is_premium],
            bot: from[:is_bot],
            language_code: from[:language_code]
          )

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
