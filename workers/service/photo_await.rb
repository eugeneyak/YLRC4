class Service::PhotoAwait < FSA::State
  include Telegram::API

  def call(update)
    case update
    in message: { photo: photo }
      state.photos << photo.max_by { it[:file_size] }.fetch(:file_id)

      FSA::State::Transit[Service::PhotosAwait]

    in message: { text: Service::ANALYZE }
      send_message state.user, "Нужно хотя бы одно изображение",
        reply_markup: {
          keyboard: [[Service::ANALYZE]],
          resize_keyboard: true,
          one_time_keyboard: true
        }

      FSA::State::Same[]
    end
  end
end
