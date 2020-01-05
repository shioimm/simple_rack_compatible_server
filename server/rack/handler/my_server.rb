require 'rack/handler'

module Rack
  module Handler
    class MyServer
      def self.run(app, options = {})
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 9292
        args = [host, port, app]
        ::MyServer::Server.new(*args).start
      end
    end

    register :my_server, MyServer
  end
end
