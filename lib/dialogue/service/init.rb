class Dialogue::Service::Init
  extend Yaks::Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  include Telegram::API

  def initialize(service, update)
    @service = service
    @update = update
  end

  attr_reader :service, :update

  def call
    update => message: { from: from }

    # Убираем reply_markup с кнопкой - она появится после первой фотографии
    send_message from, text

    FSA::State::Transit[Dialogue::Service::PhotoAwait]
  end

  def text
    if Random.rand(1..10_000) < 10_000
      "Нужно загрузить изображения автомобиля"
    else
      "Кидай нюдсы))"
    end
  end
end
