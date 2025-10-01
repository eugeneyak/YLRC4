class Start < FSA::Machine

  class Context
    attr_accessor :trace_id
  end

  def ctx = Start::Context.new

  def init = Start::Init
end
