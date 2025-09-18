class Service::Analyzer
  DASHBOARD = "dashboard".freeze
  VIN = "vin".freeze
  PLATE = "plate".freeze
  NOTHING = "nothing".freeze

  def initialize(file_id, priority: 0)
    @file_id = file_id
    @priority = priority
    @ai = AI.new
  end

  def call
    Telegram::Client.instance.get("getFile", file_id: @file_id) => file_path: file_path
    Telegram::Client.instance.download(file_path) { recognize it }
  end

  private

  def recognize(file)
    classification = @ai.ask "Classify the image as [#{DASHBOARD}, #{VIN}, #{PLATE}, #{NOTHING}]", with: file.path

    case classification
    when DASHBOARD then { odometer: @ai.ask("parse the odometer value and return a number only").to_i }
    when VIN       then { vin: @ai.ask("parse the vin and return a value only") }
    when PLATE     then { plate: @ai.ask("parse the plate and return value in format А123БВ12") }
    when NOTHING   then {}
    else
      Console.info self, "skip image"
      {}
    end
  rescue RubyLLM::OverloadedError => e
    Console.error self, "#{@ai.model} is overloaded"

    if next_model = AI::MODELS[@priority + 1]
      Console.error self, "Model rotation: #{next_model}"
      @ai = AI.new(model: next_model)
      retry
    else
      raise e
    end
  end
end
