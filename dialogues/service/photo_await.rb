class Dialogue::Service::PhotoAwait
  extend Interactor

  include Telegram::API

  def initialize(service, update)
    @service = service
    @update = update
  end

  attr_reader :service, :update

  def call
    case update
    in message: { photo: photo }
      service.update(
        photos: Sequel.pg_array([*service.photos, photo.max_by { it[:file_size] }.fetch(:file_id)])
      )

      FSA::State::Same[]

    in message: { text: Dialogue::Service::ANALYZE, from: from } if service.photos.count.zero?
      send_message from, "Нужно хотя бы одно изображение",
        reply_markup: {
          keyboard: [[Dialogue::Service::ANALYZE]],
          resize_keyboard: true,
          one_time_keyboard: true
        }

      FSA::State::Same[]

    in message: { text: Dialogue::Service::ANALYZE, from: from } if service.message_ids.count.positive?
      Console.info self, "пропуск публикации"
      Dialogue::Service::Solver.enqueue(service.id)

    in message: { text: Dialogue::Service::ANALYZE, from: from } if service.photos.count.positive?
      name = "#{from[:first_name]} #{from[:last_name]}".strip

      message_ids = service.photos.each_slice(10).map do |batch|
        payload = batch.map.with_index do |photo, index|
          if index.zero?
            {
              type: "photo",
              media: photo,
              show_caption_above_media: true,
              caption_entities: [{ type: "text_mention", offset: 0, length: name.length, user: from }],
              caption: <<~TXT
                #{name} принял автомобиль
              TXT
            }
          else
            { type: "photo", media: photo, show_caption_above_media: true }
          end
        end

        send_media_group(Config::CHANNEL, payload.to_a)
          .map { |message| message[:message_id] }
      end

      service.update(
        message_ids: Sequel.pg_array(message_ids.flatten)
      )

      Dialogue::Service::Solver.enqueue(service.id)

      FSA::State::Same[]
    end
  end
end
