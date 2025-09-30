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

      cur = @commands[command].build

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

    in message: { from: from } if @workers.member? from[:id]
      cur = @workers[from[:id]]

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

    else
      Console.info self, "Skipping unknown update", **update
    end
  end
end
