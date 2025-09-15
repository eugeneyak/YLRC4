class Service::Init < FSA::State
  include Telegram::API

  def call(update)
    update => message: { from: from }

    state.user = from

    send_message from, text,
      reply_markup: {
        keyboard: [[Service::ANALYZE]],
        resize_keyboard: true,
        one_time_keyboard: true
      }

    FSA::State::Transit[Service::PhotoAwait]
  end

  def text
    if Random.rand(1..10_000) < 10_000
      "Нужно загрузить изображения автомобиля"
    else
      "Кидай нюдсы"
    end
  end
end
