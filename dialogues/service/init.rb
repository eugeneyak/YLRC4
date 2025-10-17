class Dialogue::Service::Init
  extend Interactor

  include Telegram::API

  def initialize(service, update)
    @service = service
    @update = update
  end

  attr_reader :service, :update

  def call
    update => message: { from: from }

    send_message from, text,
      reply_markup: {
        keyboard: [[Dialogue::Service::ANALYZE]],
        resize_keyboard: true,
        one_time_keyboard: true
      }

    FSA::State::Transit[Dialogue::Service::PhotoAwait]
  end

  def text
    if Random.rand(1..10_000) < 10_000
      "Нужно загрузить изображения автомобиля"
    else
      "Кидай нюдсы"
    end
  end
end
