require "ruby_llm"
require "ruby_llm/schema"

class AI
  MODELS = [
    "gemini-2.0-flash-lite".freeze,
    "gemini-2.5-flash-lite".freeze
  ].freeze

  def initialize(model: MODELS.first)
    @model = model
  end

  attr_reader :model

  def ask(prompt, ...)
    response = chat.ask(prompt, ...)

    Console.info self,
      "Prompt: #{prompt}",
      "Response: #{response.content}",
      "Input Tokens: #{response.input_tokens}",
      "Output Tokens: #{response.output_tokens}"

    response.content.chomp
  end

  private

  def chat
    @chat ||= begin
      llm = RubyLLM.context do |config|
        config.gemini_api_key = Config::GEMINI_API_KEY
        config.default_model = model
      end

      llm.chat.with_temperature(0)
    end
  end
end
