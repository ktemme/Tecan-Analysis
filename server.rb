require 'rubygems'
require 'sinatra'
require 'analyze'
require 'analyze_rena_data'

get '/' do
  erb :index
end

post '/analyze' do
  f = params[:datafile][:tempfile]
  white = params[:white]
  time = params[:timepoint]
  analyze_data(f,{:white => white.to_i, :time => time})
end

post '/rena' do
  f = params[:datafile][:tempfile]
  white = params[:white]
  time = params[:timepoint]
  fp = params[:fp]
  analyze_rena_data(f,{:white => white.to_i, :time => time, :fp => fp})
end
