class Interactor::Do
  def call(&block)
    receiver = block.binding.receiver
    stack.push receiver

    receiver
      .class
      .middlewares
      .reverse
      .reduce(block) { |stack, middleware| middleware.new(receiver, stack) }
      .call
  ensure
    stack.pop
  end

  private

  def stack
    Interactor::Stack.instance ||= Interactor::Stack.new
  end
end
