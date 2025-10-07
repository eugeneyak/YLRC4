class Interactor::Middleware
  def initialize(receiver)
    @receiver = receiver
  end

  def call = yield

  protected

  attr_reader :receiver

  private

  def stack = Interactor::Stack.instance || []
end
