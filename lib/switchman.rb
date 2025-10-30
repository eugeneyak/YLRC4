class Switchman
  extend Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  def initialize(update)
    @update = update
  end

  attr_reader :update

  def call
    case update
    in update_id: update_id, message: { from: from }
      Sentry.configure_scope do |scope|
        scope.set_context("update", update)
        scope.set_tag("update_id", update_id)
      end

      step =
        case update
        in message: { text: "/start" }
          init_dialogue Dialogue::Start, nil

        in message: { text: "/service" }
          init_dialogue Dialogue::Service::Init, Service

        in message: _ if (dialogue = DB.from(:dialogues).first(user_id: from[:id], completed_at: nil))
          dialogue => step: step_str, entity: entity_str, entity_id: entity_id

          step_cls = step_str.split("::").reduce(Object) { |a, e| a.const_get(e) }
          entity_cls = entity_str.split("::").reduce(Object) { |a, e| a.const_get(e) }

          step_cls.new(entity_cls[entity_id], update)

        else
          -> { FSA::State::Same[] }
        end

      case step.call
      in FSA::State::Same
        :noop

      in FSA::State::Transit[nxt]
        DB.from(:dialogues)
          .where(user_id: from[:id], completed_at: nil)
          .update(step: nxt.name)

      in FSA::State::Terminate
        DB.from(:dialogues)
          .where(user_id: from[:id], completed_at: nil)
          .update(step: nil, completed_at: Sequel::CURRENT_TIMESTAMP)
      end

    else
      :noop
    end
  end

  def init_dialogue(step_cls, entity_cls)
    update => update_id: update_id, message: { from: from }

    entity = entity_cls.create(id: update_id, user_id: from[:id]) if entity_cls

    DB.from(:dialogues).where(user_id: from[:id], completed_at: nil).delete
    DB.from(:dialogues).insert(
      user_id: from[:id],
      trace_id: transaction.trace_id,
      step: step_cls.name,
      entity: entity_cls&.name,
      entity_id: entity&.id
    )

    step_cls.new(entity, update)
  end

  def transaction
    Sentry.get_current_scope.get_transaction
  end
end
