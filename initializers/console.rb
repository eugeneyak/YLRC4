require "console"

require_relative '../lib/config'

Console.logger.debug! if Config::DEV
