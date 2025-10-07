class Interactor::Do
  def call(&block)
    receiver = block.binding.receiver
    stack.push receiver

    callables = receiver.class.middlewares.map do
      it.new(receiver).method(:call).to_proc
    end

    callables << block

    callables.reduce { |res, proc| res.call(&proc) }
  ensure
    stack.pop
  end

  private

  def stack
    Interactor::Stack.instance ||= Interactor::Stack.new
  end
end
