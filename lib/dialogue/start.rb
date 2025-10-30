class Dialogue::Start
  extend Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  include Telegram::API

  def initialize(_service, _update); end

  attr_reader :update

  def call
    FSA::State::Terminate[]
  end
end
