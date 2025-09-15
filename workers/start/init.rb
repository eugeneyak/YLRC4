class Start::Init < FSA::State
  include Telegram::API

  def call(_update)
    FSA::State::Terminate[]
  end
end
