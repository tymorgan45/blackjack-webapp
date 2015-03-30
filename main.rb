require 'rubygems'
require 'sinatra'

set :sessions, true

get '/template' do
  erb :mytemplate
end


