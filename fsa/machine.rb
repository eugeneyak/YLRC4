class FSA::Machine
  def init
    raise NotImplementedError, "Subclass must implement #init"
  end

  def ctx
    raise NotImplementedError, "Subclass must implement #ctx"
  end

  def build
    init.new(ctx)
  end
end
