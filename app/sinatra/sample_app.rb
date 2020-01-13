require 'sinatra'
require_relative '../../server/simple_rack_compatible_server'

get '/' do
  'Hello. This app is running on Simple Rack Compatible Server.'
end
