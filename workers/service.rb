class Service < FSA::Machine
  ANALYZE = "Отправить".freeze

  class Context
    def initialize
      @photos = []
    end

    attr_accessor :user, :photos, :trace_id

    def to_h
      { user: user, photos: photos }
    end

    def deconstruct_keys(keys)
      keys
        .map { |key| [key, instance_variable_get(:"@#{key}")] }
        .to_h
    end
  end

  def ctx = Service::Context.new

  def init = Service::Init
end
