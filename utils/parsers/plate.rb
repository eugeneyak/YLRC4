module Utils
  module Parser
    class Plate
      extend Interactor

      FORMAT = /(?<prefix>[А-Я])[[:space:]]?(?<number>\d{3})[[:space:]]?(?<suffix>[А-Я]{2})[[:space:]]?(?<region>\d{2,3})/

      def initialize(value)
        @value = value.upcase
      end

      attr_reader :value

      def call
        [match[:prefix], match[:number], match[:suffix], " ", match[:region]].join if match
      end

      def match
        @match ||= FORMAT.match(value)
      end
    end
  end
end
