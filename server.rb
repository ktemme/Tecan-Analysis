require 'sinatra'
require 'analyze'
require 'analyze_rena_data'
require 'sinatra/static_assets'


before do
  # request.env['PATH_INFO'] = '/' if request.env['PATH_INFO'].empty?
end

get '/?' do
  erb :index
end

post '/analyze' do
  f = params[:datafile][:tempfile]
  white = params[:white]
  time = params[:timepoint]
  layout = eval(params[:layout])
  analyze_data(f,{:white => white.to_i, :time => time, :layout => layout})
end

post '/rena' do
  f = params[:datafile][:tempfile]
  white = params[:white]
  time = params[:timepoint]
  fp = params[:fp]
  analyze_rena_data(f,{:white => white.to_i, :time => time, :fp => fp})
end
