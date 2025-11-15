require "async/http/internet/instance"

class Telegram::Client
  extend Fiber::Local

  HOST = "https://api.telegram.org".freeze

  def initialize(token, ssl_context: OpenSSL::SSL::SSLContext.new)
    @token = token
    @silent = false

    @client = Async::HTTP::Client.new(
      Async::HTTP::Endpoint.parse(HOST, ssl_context: ssl_context)
    )
  end

  def silent(&)
    @silent = true
    yield
  ensure
    @silent = false
  end

  def download(path)
    uri  = URI::HTTP.build(path: "/file/bot#{@token}/#{path}")
    file = Tempfile.new(path)

    response = @client.get(uri.request_uri)

    response.body.each { |chunk| file << chunk }

    file.rewind

    if block_given?
      result = yield file
      file.unlink
      result
    else
      file
    end

  ensure
    response.close if response
  end

  def get(method, **params)
    Console.info self, "Invoke #{method}", **params unless @silent

    uri = URI::HTTP.build(
      path: "/bot#{@token}/#{method}",
      query: params.compact.any? ? URI.encode_www_form(params.compact) : nil
    )

    response = @client.get(uri.request_uri)

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
  ensure
    response.close if response
  end

  def post(method, **params)
    Console.info self, "Invoke #{method}", **params unless @silent

    uri = URI::HTTP.build(path: "/bot#{@token}/#{method}")
    headers = Protocol::HTTP::Headers["Content-Type" => "application/json"]
    body = JSON.dump(params.compact)

    response = @client.post(uri.request_uri, headers, body)
    data = JSON.parse(response.read, symbolize_names: true)

    case data
    in ok: true, result: result
      Console.info self, result
      result

    in ok: false, error_code: 401, description: description
      raise Telegram::UnauthorizedError, description

    in ok: false, description: description
      Console.error self, description
      raise Telegram::Error, description

    else
      raise RuntimeError
    end

  ensure
    response.close if response
  end
end
