class FSA::State
  def initialize(state = {})
    @state = state
  end

  attr_accessor :state

  def __call__(update)
    Sentry.with_child_span(op: self.class.name) do |span|
      call(update)
    end
  end

  def call(_update); end
end

class FSA::State::Transit
  def self.[](nxt) = new(nxt)

  def initialize(nxt)
    @nxt = nxt
  end

  def deconstruct = [@nxt]
end

class FSA::State::Same
  def self.[] = new

  def deconstruct = []
end

class FSA::State::Terminate
  def self.[] = new

  def deconstruct = []
end
