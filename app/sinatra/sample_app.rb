require 'sinatra'
require_relative '../../server/simple_rack_compatible_server'

get '/' do
  erb :index
end

get '/posts/new' do
  erb :new
end

post '/posts' do
  @post = params[:post]
  erb :show
end
