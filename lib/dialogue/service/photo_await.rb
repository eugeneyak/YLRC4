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

    in message: { text: Dialogue::Service::COMMIT, from: from } if service.photos.count.zero?
      send_message from, "Нужно хотя бы одно изображение",
        reply_markup: {
          keyboard: [[Dialogue::Service::COMMIT]],
          resize_keyboard: true,
          one_time_keyboard: true
        }

      FSA::State::Same[]

    in message: { text: Dialogue::Service::COMMIT } if service.message_ids.count.positive?
      Console.info self, "пропуск публикации"
      FSA::State::Same[]

    in message: { message_id: message_id, text: Dialogue::Service::COMMIT, from: from } if service.photos.count.positive?
      name = "#{from[:first_name]} #{from[:last_name]}".strip

      groups = service.photos.each_slice(10).map do |photos|
        Dialogue::Service::Utils::Captor.new(
          photos,
          caption: "#{name} принял автомобиль",
          entities: [{ type: "text_mention", offset: 0, length: name.length, user: from }]
        ).call
      end

      message_ids = groups.map do |photos|
        mids = send_media_group(Config::CHANNEL, photos.to_a)
        p mids
        mids.first[:message_id]
      end

      service.update(message_ids: Sequel.pg_array(message_ids.flatten))

      Dialogue::Service::Jobs::Analyze.enqueue(service.id)

      set_message_reaction(from, message_id, "👌", big: false)

      FSA::State::Terminate[]
    end
  end
end
