if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'
require 'scrumy_client'

get '/' do
  erb :index
end

post '/' do
  @results = ""
  idx=0
  begin
    params[:project].each{ |project|
      name = project['name']
      password = project['password']
      client = ScrumyClient.new(name, password)
      @results << client.regression_steps(idx == 0).to_csv
      idx += 1
    }
    erb :results
  rescue => e   
    @error = e.message
    erb :index
  end
end