require 'socket'
require_relative './rack/handler/my_server'

module MyServer
  class Server
    def self.stringio_encode(content = '')
      io = StringIO.new(content)
      io.binmode
      io.set_encoding "ASCII-8BIT" if io.respond_to? :set_encoding
      io
    end

    RACK_ENV = {
      'PATH_INFO' => '/',
      'QUERY_STRING' => '',
      'REQUEST_METHOD' =>'GET',
      'SERVER_NAME' => 'MY_SERVER',
      'SERVER_PORT' => @port.to_s,
      'rack.version' => Rack::VERSION,
      'rack.input' => stringio_encode,
      'rack.errors' => $stderr,
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'rack.url_scheme' => 'http',
    }

    def initialize(*args)
      @host, @port, @app = args
    end

    def start
      server = TCPServer.open(@port)

      while true
        socket = server.accept

        req = []

        begin
          while message = socket.gets
            req << message
            break if message.chomp.empty?
          end

          status, header, body = @app.call(RACK_ENV.merge(req[1..-2].map { |a| a.split(': ') }.to_h))

          status = "HTTP/1.1 200 OK" if status.eql? 200

          res = <<~HTTP
            #{status}
            #{header.map { |k, v| "#{k}: #{v}" }.join(', ')}\r\n

            # body will be here
          HTTP

          socket.puts res
        ensure
          socket.close
        end
      end
    end
  end
end
