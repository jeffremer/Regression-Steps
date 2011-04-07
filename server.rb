if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'
require 'gchart'
require 'scrumy_client'

get '/' do
  erb :index
end

get '/burndown' do
  erb :burndown
end

post '/burndown' do
  days = Hash.new
  @results = ""
  begin
    params[:project].each{ |project|
      name = project['name']
      password = project['password'].empty? ? params[:master_password] : project['password']
      sprint = project['sprint'].empty? ? 'current' : project['sprint']
      if name && password        
          client = ScrumyClient.new(name, password)
          snapshots = client.snapshots(sprint)
          snapshots.each{|snapshot|
            s = snapshot['snapshot']
            if !days.has_key?(s['snapshot_date'])
              days[s['snapshot_date']] = {'date'=>s['snapshot_date'], 'total' => s['hours_total'], 'remaining'=>s['hours_remaining']}
            else
              day = days[s['snapshot_date']]
              day['total'] += s['hours_total']
              day['remaining'] += s['hours_remaining']
            end              
          }
      end
    }

    if days.empty?
      throw "No data for this sprint"
    end
    
    sorted = days.values.sort_by{|day|day['date']}

    actual = sorted.collect{|day|day['remaining']}.unshift(sorted.first['total'])
    (7-actual.size).times{|e|actual.push(-1)}
    expected = [sorted.first['total'],0]
   
    start_date = Date.strptime(sorted.first['date'], "%Y-%m-%d")
    
    @graph_url = Gchart.line(
      :title => "Burndown #{(start_date-1).strftime("%m-%d")} to #{(start_date+6).strftime("%m-%d")}",
      :legend => ['Actual', 'Expected'],
      :line_colors => "00C25B,007EFF",
      :size=> '500x375',
      :data=>[actual, expected],
      :axis_with_labels => 'x,y',
      :axis_labels => [[start_date-1, start_date+6].collect{|d|d.strftime("%m-%d")}.unshift(0), expected.reverse],
      :axis_range => [[0,7]],
      :encoding => 'text',
      :custom => "chxp=0,0,1,7&chds=0,#{expected.first},0,#{expected.first}"        
    )
    # Workaround for datascaling
    @graph_url.gsub!(/chds=-1/, 'chds=0')
    
    erb :graph
  rescue => e   
    @error = e.message
    erb :burndown
  end    
end  

get '/regression' do
  erb :regression
end

post '/regression' do
  @results = ""
  idx=0
  begin    
    params[:project].each{ |project|
      name = project['name']
      password = project['password'].empty? ? params[:master_password] : project['password']
      if name && password
        client = ScrumyClient.new(name, password)
        @results << client.regression_steps(idx == 0).to_csv
      end
      idx += 1
    }
    erb :results
  rescue => e   
    @error = e.message
    erb :regression
  end
end