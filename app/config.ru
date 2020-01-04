require 'rack'
require_relative '../server/my_server'

class App
  def call(env)
    [200, { 'Content-Type' => 'text/html' }, ["<div><h1>hoge</h1><p>hoge</p></div>"]]
  end
end

run App.new
