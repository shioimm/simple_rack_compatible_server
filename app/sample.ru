require 'rack'
require_relative '../server/simple_rack_compatible_server'

class App
  def call(env)
    [200, { 'Content-Type' => 'text/html' }, ["<div><h1>hoge</h1><p>hoge</p></div>"]]
  end
end

run App.new
