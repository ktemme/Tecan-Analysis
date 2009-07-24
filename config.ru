require 'rubygems'
require 'sinatra'


set :run, false
set :env, :production
set :raise_errors, true

log = File.new("sinatra.log", "a+")
STDOUT.reopen(log)
STDERR.reopen(log)

require 'server.rb'
run Sinatra::Application
