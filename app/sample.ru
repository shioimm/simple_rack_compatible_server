require 'rack'
require_relative '../server/simple_rack_compatible_server'

class App
  def call(env)
    [
      200,
      { 'Content-Type' => 'text/html' },
      ["<div><h1>Hello</h1><p>This app is running on Simple Rack Compatible Server.</p></div>"]
    ]
  end
end

run App.new
