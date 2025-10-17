require "async"

require_relative "../../telegram"

class Dialogue::Service::Solver < Que::Job
  include Telegram::API

  class CarSchema < RubyLLM::Schema
    string :brand
    string :model
    string :vin
    string :plate, pattern: "А111АА11, only Cyrillic is allowed", min_length: 8, max_length: 9
    number :mileage
  end

  def run(service_id)
    service = Service[service_id]
    files = download_files(service.photos)
    content = analyze(files)

    service.update(
      brand: content["brand"],
      model: content["model"],
      vin: content["vin"],
      plate: content["plate"],
      mileage: content["mileage"]&.to_i
    )

    update_messages(service.message_ids, service)
  ensure
    files.each(&:unlink)
  end

  attr_reader :service

  private

  def download_files(file_ids)
    Sync do |task|
      file_ids
        .map { |file_id| task.async { download_file(file_id) } }
        .map(&:wait)
    end
  end

  def download_file(file_id)
    Telegram::Client.instance.get("getFile", file_id: file_id) => file_path: file_path
    Telegram::Client.instance.download(file_path)
  end

  def analyze(files)
    response = AI.new.chat
                 .with_schema(CarSchema)
                 .ask("determine the car plate number, car mileage, car vin, car brand, car model", with: files.map(&:path))

    response.content.compact.tap do |content|
      p content
    end
  end

  def update_messages(message_ids, update)
    Sync do |task|
      barrier = Async::Barrier.new(parent: task)

      message_ids.each do |message_id|
        barrier.async do
          car = "#{update[:brand]} #{update[:model]}".strip

          caption = <<~TXT
            #{car}

            VIN: #{update[:vin].upcase}
            Номер а/м: #{update[:plate].upcase}
            Одометр: #{update[:mileage]}
          TXT

          edit_message_caption(Config::CHANNEL, message_id, caption, show_caption_above_media: true)
        end
      end

      barrier.wait
    end
  end
end
