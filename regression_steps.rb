require 'json'
require 'rest_client'
require 'fastercsv'

class RegressionSteps
  attr_reader :url
  def initialize(project, password)
    @project, @password = project, password
    @url = "https://#{@project}:#{@password}@scrumy.com/api/scrumies/#{@project}/sprints/current.json"
  end
  
  def get
    @url = "https://#{@project}:#{@password}@scrumy.com/api/scrumies/#{@project}/sprints/current.json"
    RestClient.get(url){|response, request, result, &block|
      case response.code
      when 200
        process_response(response.to_str)
      else
        response.return!(request, result, &block)
      end
    }  
  end
  
  def process_response(response_text)
    response = JSON.parse(response_text)
    response['sprint']['stories'].collect{|story|
      if !story['story']['tasks'].nil?
        [story['story']['title']].push(
          story['story']['tasks'].collect{|task|
            task['task']['scrumer']['name']
          }.uniq().reject{|n| n == 'info'}.join(', ')
        )
      else
        [story['story']['title']]
      end
    }.unshift(['Scrumy Item', 'Worked On'])
  end
end

class Array
  def to_csv
    str=''
    FasterCSV.generate(str, :col_sep => "\t") do |csv|
      self.each do |r|
        csv << r
      end
    end
    str
  end
end