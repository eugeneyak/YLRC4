class Dialogue::Service::Utils::Solver
  class CarSchema < ::RubyLLM::Schema
    string :brand
    string :model
    string :vin
    string :plate, pattern: "А111БВ22", min_length: 8, max_length: 9
    number :mileage
  end

  extend Yaks::Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  def initialize(service)
    @service = service
  end

  attr_reader :service

  def call
    files = download_files(service.photos)
    answer = ask(files).tap { p it }
    check(answer).tap { p it }

  ensure
    files.each &:unlink if files
  end

  private

  def download_files(file_ids)
    # Sync do |task|
      file_ids
        .map { |file_id| Async { download_file(file_id) } }
        .map(&:wait)
    # end
  end

  def download_file(file_id)
    Telegram::Client.instance.get("getFile", file_id: file_id) => file_path: file_path
    Telegram::Client.instance.download(file_path)
  end

  def ask(files)
    # prompt = "Determine the car plate number, car mileage, car vin, car brand, car model. " \
    #   "Use only Cyrillic letters for the license plate."

    prompt = "Распознай регистрационный номер, пробег, VIN, производителя автомобиля, модель автомобиля"

    response = AI.new.chat.with_schema(CarSchema).ask(prompt, with: files.map(&:path))

    response.content.compact
  end

  def check(answer)
    {
      brand: answer["brand"],
      model: answer["model"],
      vin: Dialogue::Service::Utils::Parser::VIN.new(answer["vin"]).call,
      plate: Dialogue::Service::Utils::Parser::Plate.new(answer["plate"]).call,
      mileage: Dialogue::Service::Utils::Parser::Mileage.new(answer["mileage"]).call
    }
  end
end
