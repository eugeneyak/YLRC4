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
    Sentry.with_child_span(op: self.class.name) do |span|
      response = chat.ask(prompt, ...)

      content = response.content.strip

      Console.info self,
        "Prompt: #{prompt}",
        "Response: #{content}",
        "Input Tokens: #{response.input_tokens}",
        "Output Tokens: #{response.output_tokens}"

      span.set_data("ai.prompt", prompt)
      span.set_data("ai.response", content)
      span.set_data("ai.input_tokens", response.input_tokens)
      span.set_data("ai.output_tokens", response.output_tokens)

      content
    end
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
