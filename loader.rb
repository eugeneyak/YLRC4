require "zeitwerk"

class Loader
  def initialize(reload: false)
    @loader = Zeitwerk::Loader.new
    @reload = reload
  end

  attr_reader :loader

  def setup
    initializers.each { require_relative it }

    loader.inflector.inflect "api" => "API", "ai" => "AI", "fsa" => "FSA", "vin" => "VIN"
    loader.push_dir("lib")
    loader.push_dir("lib/models")
    loader.ignore("lib/migrations")
    loader.ignore("lib/workers")
    loader.enable_reloading if reload?
    loader.setup

    loader.eager_load
  end

  def reload!
    loader.reload if loader.reloading_enabled?
  end

  private

  def reload? = @reload

  def initializers
    files = File.join(__dir__, "initializers", "*.rb")
    Dir[files]
  end
end
