require "que"

require_relative "sequel"

Que.connection = DB
# Que::Job.run_synchronously = true if Config::DEV
