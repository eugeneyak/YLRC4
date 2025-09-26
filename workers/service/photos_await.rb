require_relative 'analyzer'

class Service::PhotosAwait < FSA::State
  PLATE_MATCHER = /[А-Я][0-9]{3}[А-Я]{2}[0-9]{2,3}/

  include Telegram::API

  def call(update)
    case update
    in message: { photo: photo }
      state => photos: photos
      photos << photo.max_by { it[:file_size] }.fetch(:file_id)

      FSA::State::Same[]

    in message: { text: Service::ANALYZE }
      data = analyze

      publish(**data.compact)

      FSA::State::Terminate[]
    end
  end

  private

  def analyze
    state => photos: photos

    data = { vin: [], plate: [], odometer: [] }

    photos
      .map { |photo| Async { Service::Analyzer.new(photo).call } }
      .each { it.wait.each { |k, v| data[k] << v if v } }

    Console.info self, **data

    data[:plate] = data[:plate].filter { PLATE_MATCHER.match? it.upcase }

    data[:odometer] = data[:odometer].compact.map(&:to_i)

    data.transform_values do |values|
      values.group_by(&:itself).max_by { |_, v| v.size }&.first
    end
  end

  def publish(vin: "", plate: "", odometer: "")
    state => user: user, photos: photos

    name = "#{user[:first_name]} #{user[:last_name]}".strip

    photos.each_slice(10) do |batch|
      payload = batch.map.with_index do |photo, index|
        if index.zero?
          {
            type: "photo",
            media: photo,
            show_caption_above_media: true,
            caption_entities: [{ type: "text_mention", offset: 0, length: name.length, user: user }],
            caption: <<~TXT
              #{name} принял автомобиль:

              VIN: #{vin.upcase}
              Номер а/м: #{plate.upcase}
              Одометр: #{odometer}
            TXT
          }
        else
          { type: "photo", media: photo, show_caption_above_media: true }
        end
      end

      send_media_group Config::CHANNEL, payload.to_a
    end
  end
end
