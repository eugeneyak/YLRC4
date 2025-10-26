class Dialogue::Service::Utils::Parser::Plate
  extend ::Interactor

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
    "X" => "Х",
    "M" => "М",
    "Y" => "У"
  }.freeze
  
  def initialize(value)
    @value = value.upcase.gsub(pattern, REPLACEMENTS)
  end

  attr_reader :value

  def call
    [match[:prefix], match[:number], match[:suffix], " ", match[:region]].join if match
  end

  def pattern = Regexp.union(REPLACEMENTS.keys)

  def match
    @match ||= FORMAT.match(value)
  end
end
