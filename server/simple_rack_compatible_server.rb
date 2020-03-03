require 'socket'
require_relative './rack/handler/simple_rack_compatible_server'

module SimpleRackCompatibleServer
  class Server
    MAX_BYTE = 1_073_741_824 # Refs to maximum length of PostgreSQL's text column

    def initialize(*args)
      @host, @port, @app = args
      @method = nil
      @path   = nil
      @scheme = nil
      @query  = nil
      @input  = nil
      @status = nil
      @header = nil
      @body   = nil
      @posted = false
    end

    def env
      {
        'PATH_INFO'         => @path   || '/',
        'QUERY_STRING'      => @query  || '',
        'REQUEST_METHOD'    => @method || 'GET',
        'SERVER_NAME'       => 'simple_rack_compatible_server',
        'SERVER_PORT'       => @port.to_s,
        'rack.version'      => Rack::VERSION,
        'rack.input'        => StringIO.new(@input || '').set_encoding('ASCII-8BIT'),
        'rack.errors'       => $stderr,
        'rack.multithread'  => false,
        'rack.multiprocess' => false,
        'rack.run_once'     => false,
        'rack.url_scheme'   => @scheme&.downcase&.slice(/http[a-z]*/) || 'http'
      }
    end

    def start
      server = TCPServer.new(@host, @port)

      puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        trap(:INT) { shutdown }

        client = server.accept

        begin
          request = []

          while buf = client.gets
            request << buf.chomp

            if request.last.empty?
              if request.first.include?('POST') || request.first.include?('PUT')
                request << client.readpartial(MAX_BYTE)
              end

              break
            end
          end

          @method, path, @scheme = request.first.split
          @path, @query = path.split('?')
          @input = request.index('') ? request[request.index('') + 1] : ''

          puts "Received request message: #{@method} #{@path} #{@scheme}"

          @status, @header, @body = @app.call(env)

          client.puts [status, header, '', body].join("\r\n")
        ensure
          client.close
        end
      end
    end

    def shutdown
      puts 'SimpleRackCompatibleServer is stopped.'
      exit
    end

    def status
      case @status
      when 200
        "#{@scheme} 200 OK"
      when 201
        "#{@scheme} 201 Created"
      when 204
        "#{@scheme} 204 NoContent"
      when 404
        "#{@scheme} 404 NotFound"
      when 500
        "#{@scheme} 500 InternalServerError"
      end
    end

    def header
      @header.map { |k, v| [k, v].join(': ') }.join("\r\n")
    end

    def body
      res_body = []
      @body.each { |body| res_body << body }
      res_body.join("\n")
    end
  end
end
