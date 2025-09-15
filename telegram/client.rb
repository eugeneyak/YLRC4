require "async/http/internet/instance"

class Telegram::Client
  extend Fiber::Local

  HOST = "api.telegram.org".freeze

  def initialize(token)
    @token = token
    @silent = false
  end

  def silent(&)
    @silent = true
    yield
  ensure
    @silent = false
  end

  def download(path)
    Async::Task.current.annotate "Downloading #{path}"

    uri  = URI::HTTPS.build(host: HOST, path: "/file/bot#{@token}/#{path}")
    file = Tempfile.new(path)

    Async::HTTP::Internet.get(uri) do |response|
      response.body.each { |chunk| file << chunk }
    end

    file.rewind

    if block_given?
      result = yield file
      file.unlink
      result
    else
      file
    end
  end

  def get(method, **params)
    Async::Task.current.annotate "Invoking #{method}"

    Console.info self, "Invoke #{method}", **params unless @silent

    uri = URI::HTTPS.build(
      host: HOST,
      path: "/bot#{@token}/#{method}", query: URI.encode_www_form(params.compact)
    )

    Async::HTTP::Internet.get(uri) do |response|
      data = JSON.parse(response.read, symbolize_names: true)

      case data
      in ok: true, result: result
        result

      in ok: false, error_code: 401, description: description
        raise Telegram::UnauthorizedError, description

      in ok: false, description: description
        Console.error self, description
        raise Telegram::Error, description

      else
        raise RuntimeError
      end
    end
  end

  def post(method, **params)
    Async::Task.current.annotate "Invoking #{method}"

    Console.info self, "Invoke #{method}", **params

    uri = URI::HTTPS.build(host: HOST, path: "/bot#{@token}/#{method}")
    headers = Protocol::HTTP::Headers["Content-Type" => "application/json"]
    body = JSON.dump(params.compact)

    Async::HTTP::Internet.post(uri, headers, body) do |response|
      data = JSON.parse(response.read, symbolize_names: true)

      case data
      in ok: true, result: result
        result

      in ok: false, error_code: 401, description: description
        raise Telegram::UnauthorizedError, description

      in ok: false, description: description
        Console.error self, description
        raise Telegram::Error, description

      else
        raise RuntimeError
      end
    end
  end
end
