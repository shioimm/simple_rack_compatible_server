require 'socket'
require_relative './rack/handler/my_server'

module MyServer
  class Server
    RACK_ENV = {
      'PATH_INFO'         => '/',
      'QUERY_STRING'      => '',
      'REQUEST_METHOD'    => 'GET',
      'SERVER_NAME'       => 'MY_SERVER',
      'SERVER_PORT'       => @port.to_s,
      'rack.version'      => Rack::VERSION,
      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'),
      'rack.errors'       => $stderr,
      'rack.multithread'  => false,
      'rack.multiprocess' => false,
      'rack.run_once'     => false,
      'rack.url_scheme'   => 'http',
    }

    def initialize(*args)
      @host, @port, @app = args
      @status = nil
      @header = nil
      @body   = nil
    end

    def start
      server = TCPServer.open(@port)

      puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      while true
        socket = server.accept

        begin
          while message = socket.gets
            puts message if message.start_with?('Host:') || message.include?('HTTP')
            break if message.chomp.empty?
          end

          @status, @header, @body = @app.call(RACK_ENV)

          socket.puts <<~MESSAGE
            #{status}
            #{header}\r\n
            #{body}
          MESSAGE
        ensure
          socket.close
        end
      end
    end

    def status
      "HTTP/1.1 200 OK" if @status.eql? 200
    end

    def header
      @header.map { |k, v| "#{k}: #{v}" }.join(', ')
    end

    def body
      res_body = []
      @body.each { |body| res_body << body }
      res_body.join("\n")
    end
  end
end
