# class Service::GroupAnalyzer
#   class CarSchema < RubyLLM::Schema
#     string :brand
#     string :model
#     string :vin
#     string :plate, pattern: "А111АА11, only Cyrillic is allowed", min_length: 8, max_length: 9
#     number :mileage
#   end
#
#   def initialize(files, priority: 0)
#     @ai = AI.new
#     @files = files
#   end
#
#   def call
#     # files = download_files
#     # data = recognize files
#     #
#     # p data
#     #
#     # data
#
#     {
#       "odometer" => 12
#     }
#   end
#
#   private
#
#   def download_files
#     @files
#       .map { |file_id| Async { download_file(file_id) } }
#       .map { |future| future.wait }
#   end
#
#   def download_file(file_id)
#     Telegram::Client.instance.get("getFile", file_id: file_id) => file_path: file_path
#     Telegram::Client.instance.download(file_path)
#   end
#
#   def recognize(files)
#     response = @ai.chat.with_schema(CarSchema)
#       .ask("determine the car plate number, car mileage, car vin, car brand, car model", with: files.map(&:path))
#
#     response.content
#   rescue RubyLLM::OverloadedError, RubyLLM::ServiceUnavailableError => e
#     Console.error self, e, model: @ai.model
#
#     if next_model = AI::MODELS[@priority + 1]
#       Console.error self, "Model rotation: #{next_model}"
#       @ai = AI.new(model: next_model)
#       retry
#     else
#       raise e
#     end
#   end
#
#   def ask(...)
#     response = @ai.ask(...)
#     response.downcase if response.split.count == 1
#   end
# end
