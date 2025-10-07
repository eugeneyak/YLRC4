require "fiber/local"
require "async"
require "delegate"

module Interactor
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
