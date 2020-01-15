require 'sinatra'
require_relative '../../server/simple_rack_compatible_server'
require_relative './content'

get '/' do
  erb :index
end

get '/contents/new' do
  erb :new
end

post '/contents' do
  Content.new(params[:content])
  @content = Content.instance.body
  erb :show
end

get '/contents/edit' do
  @content = Content.instance.body
  erb :edit
end

put '/contents' do
  Content.instance.body = params[:content]
  @content = Content.instance.body
  erb :show
end

delete '/contents' do
  Content.instance.body = nil
  @content = Content.instance.body
  erb :show
end
