class Dialogue::Service::Utils::Parser::Plate
  extend Yaks::Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  FORMAT = /(?<prefix>[А-Я])[[:space:]]?(?<number>\d{3})[[:space:]]?(?<suffix>[А-Я]{2})[[:space:]]?(?<region>\d{2,3})/

  REPLACEMENTS = {
    "A" => "А",
    "B" => "В",
    "C" => "С",
    "E" => "Е",
    "H" => "Н",
    "O" => "О",
    "P" => "Р",
    "K" => "К",
    "T" => "Т",
    "X" => "Х",
    "M" => "М",
    "Y" => "У"
  }.freeze

  def initialize(value)
    @value = value
  end

  attr_reader :value

  def call
    out = [match[:prefix], match[:number], match[:suffix], " ", match[:region]].join if match

    span = Sentry.get_current_scope.get_span
    span.set_data("in", value)
    span.set_data("out", out)

    out
  end

  def pattern = Regexp.union(REPLACEMENTS.keys)

  def match
    @match ||= FORMAT.match(value.upcase.gsub(pattern, REPLACEMENTS))
  end
end
