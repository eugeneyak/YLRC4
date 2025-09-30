class Service::Analyzer
  DASHBOARD = "dashboard".freeze
  VIN = "vin".freeze
  PLATE = "plate".freeze
  CAR = "car".freeze
  NOTHING = "nothing".freeze

  def initialize(file_id, priority: 0)
    @file_id = file_id
    @priority = priority
    @ai = AI.new
  end

  def call
    Sentry.with_child_span(op: self.class.name) do
      Async::Task.current.annotate "Analyze #{@file_id} photo"

      Telegram::Client.instance.get("getFile", file_id: @file_id) => file_path: file_path
      Telegram::Client.instance.download(file_path) { recognize it }
    end
  end

  private

  def recognize(file)
    case classification = ask("Classify the image as [#{DASHBOARD}, #{VIN}, #{CAR}, #{NOTHING}]. Answer in one word.", with: file.path)
    when DASHBOARD
      { odometer: ask("Parse the odometer value. Return only the number.") }

    when VIN
      { vin: ask("Parse the vin and return only the value") }

    when CAR
      case ask("Classify readability of the plate as [good, bad]. Answer in one word.")
      when "good"
        { plate: ask("Parse the plate and return value in format А123БВ12. Use only Cyrillic alphabet.") }

      else
        {}
      end

    else
      Console.info self, "skip: #{classification}"
      {}
    end
  rescue RubyLLM::OverloadedError, RubyLLM::ServiceUnavailableError => e
    Console.error self, e, model: @ai.model

    if next_model = AI::MODELS[@priority + 1]
      Console.error self, "Model rotation: #{next_model}"
      @ai = AI.new(model: next_model)
      retry
    else
      raise e
    end
  end

  def ask(...)
    response = @ai.ask(...)
    response.downcase if response.split.count == 1
  end
end
