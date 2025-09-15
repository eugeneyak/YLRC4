class Service::Analyzer
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
    classification = @ai.ask "Classify the image as [dashboard, vin, plate, nothing]", with: file.path

    case classification
    when "dashboard" then { odometer: @ai.ask("parse the odometer value and return a number only").to_i }
    when "vin"       then { vin: @ai.ask("parse the vin and return a value only") }
    when "plate"     then { plate: @ai.ask("parse the plate and return value in format А123БВ12") }
    else Console.info self, "skip image"
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
