class Dialogue::Service::Utils::Parser::Mileage
  extend ::Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  def initialize(value)
    @value = value
  end

  attr_reader :value

  def call
    i = value.to_i
    i if i.positive?
  rescue StandardError
    nil
  end
end
