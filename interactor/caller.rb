module Interactor::Caller
  def call(...)
    Interactor::Do.new.call { super(...) }
  end
end
