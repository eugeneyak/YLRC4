module Dialogue; end

class Dialogue::Service
  require_relative "service/init"
  require_relative "service/photo_await"
  require_relative "service/solver"

  ANALYZE = "Тралала".freeze
end
