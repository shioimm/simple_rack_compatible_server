require 'socket'
require_relative './rack/handler/my_server'

module MyServer
  class Server
    RACK_ENV = {
      'PATH_INFO'         => @path || '/',
      'QUERY_STRING'      => '',
      'REQUEST_METHOD'    => @method || 'GET',
      'SERVER_NAME'       => 'MY_SERVER',
      'SERVER_PORT'       => @port.to_s,
      'rack.version'      => Rack::VERSION,
      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'),
      'rack.errors'       => $stderr,
      'rack.multithread'  => false,
      'rack.multiprocess' => false,
      'rack.run_once'     => false,
      'rack.url_scheme'   => @schema&.downcase&.slice(/http[a-z]*/) || 'http'
    }

    def initialize(*args)
      @host, @port, @app = args
      @method = nil
      @path   = nil
      @schema = nil
      @status = nil
      @header = nil
      @body   = nil
    end

    def start
      server = TCPServer.new(@host, @port)

      puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        client = server.accept

        begin
          request = client.readpartial(2048)
          @method, @path, @schema = request.split("\r\n").first.split

          puts "Received request message: #{@method} #{@path} #{@schema}"

          @status, @header, @body = @app.call(RACK_ENV)

          client.puts <<~MESSAGE
            #{status}
            #{header}\r\n
            #{body}
          MESSAGE
        ensure
          client.close
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
