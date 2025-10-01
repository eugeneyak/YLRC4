require "securerandom"

class FSA::Switchman
  def initialize
    @workers = {}
    @commands = {}
  end

  def register(hash)
    hash.each do |command, machine|
      @commands["/#{command}"] = machine.new
    end
  end

  def <<(update)
    case update
    in message: { from: from, text: command } if @commands.member? command
      Console.info self, "Start #{command} for #{from[:id]}"
      handle update, @commands[command].build

    in message: { from: from } if @workers.member? from[:id]
      handle update, @workers[from[:id]]

    else
      Console.info self, "Skipping unknown update", **update
    end
  end

  def handle(update, cur)
    sentry_opts = { trace_id: cur.state.trace_id }.compact

    transaction = Sentry.start_transaction(name: "Update #{update[:update_id]}", **sentry_opts)
    Sentry.get_current_scope.set_span(transaction) if Sentry.get_current_scope && transaction

    cur.state.trace_id ||= transaction.trace_id

    update => message: { from: from }

    case cur.__call__(update)
    in FSA::State::Transit[nxt]
      Console.info self, "Transit to #{nxt} with", **cur.state.to_h
      @workers[from[:id]] = nxt.new(cur.state)
    in FSA::State::Same
      Console.info self, "State stays same", **cur.state.to_h
      @workers[from[:id]] = cur
    in FSA::State::Terminate
      Console.info self, "FSA terminates"
      @workers.delete(from[:id])
    end

  ensure
    transaction.finish
  end
end
