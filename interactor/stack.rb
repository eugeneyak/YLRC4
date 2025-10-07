class Interactor::Stack < Delegator
  extend Fiber::Local

  def initialize
    super([])
  end

  attr_reader :stack

  def __getobj__
    @stack
  end

  def __setobj__(obj)
    @stack = obj
  end
end
