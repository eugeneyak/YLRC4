class Dialogue::Service::Utils::Parser::VIN
  extend ::Interactor

  FORMAT = /[0-9A-Z]{17}/

  def initialize(value)
    @value = value.upcase
  end

  attr_reader :value

  def call
    value if FORMAT === value
  end
end
