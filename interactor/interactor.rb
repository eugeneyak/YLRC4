require "fiber/local"
require "delegate"

module Interactor
  require_relative "caller"
  require_relative "do"
  require_relative "middleware"
  require_relative "stack"

  def self.extended(base)
    base.prepend Interactor::Caller

    base.define_singleton_method :inherited do |inherited|
      inherited.prepend Interactor::Caller
    end
  end

  def use(middleware)
    middlewares << middleware
  end

  def middlewares
    @middlewares ||=
      superclass.respond_to?(:middlewares) ? superclass.middlewares.dup : []
  end
end
