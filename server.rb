if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'
require 'regression_steps.rb'

get '/' do
  erb :index
end

post '/' do
  steps = RegressionSteps.new(params[:project], params[:password])
  begin
    @results = steps.get().to_csv
    erb :results
  rescue => e   
    @error = e.message
    erb :index
  end
end