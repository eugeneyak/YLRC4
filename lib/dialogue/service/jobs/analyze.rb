require "async"
require "ruby_llm"
require "ruby_llm/schema"

class Dialogue::Service::Jobs::Analyze < Que::Job
  include Telegram::API

  def run(service_id)
    Sync do |task|
      Telegram::Bot.new(Config::Telegram::TOKEN)

      DB.transaction do
        service = Service[service_id]
        user = User[service.user_id]

        data = Dialogue::Service::Utils::Solver.new(service).call

        service.update(**data)

        name = "#{user[:first_name]} #{user[:last_name]}".strip
        car = "#{data[:brand]} #{data[:model]}".strip

        caption = []
        caption << "#{name} принял #{car}:"
        caption << ""
        caption << "VIN: #{data[:vin]}" if data[:vin]
        caption << "Номер А/М: #{data[:plate]}" if data[:plate]
        caption << "Пробег: #{data[:mileage]}" if data[:mileage]

        service.message_ids.each do |message_id|
          edit_message_caption(
            Config::CHANNEL,
            message_id,
            caption.join("\n"),
            caption_entities: [{ type: "text_mention", offset: 0, length: name.length, user: { id: user.id } }],
            show_caption_above_media: true
          )
        end

        finish

      rescue RubyLLM::BadRequestError
        p "shtosh"

      rescue StandardError => e
        Console.error self, e
        Sentry.capture_exception e
        retry_in_default_interval
      end
    end
  end

end
