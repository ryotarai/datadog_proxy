require 'datadog_proxy'
require 'sinatra'
require 'chronic'

module DatadogProxy
  class App < Sinatra::Application
    class Error < StandardError; end

    def initialize(*args)
      super(*args)
    end

    def client
      @_client ||= DatadogClient.new(ENV['DATADOG_API_KEY'], ENV['DATADOG_APP_KEY'])
    end

    get '/' do
      <<-EOMD
# Datadog Proxy
## Endpoints
### GET /graphs/snapshot
#### Parameters
* query
* start: seconds since unix epoch
* end: seconds since unix epoch
* duration: seconds
      EOMD
    end

    get '/graphs/snapshot' do
      if params.empty?
        return erb(:snapshot)
      end

      options = {}
      options[:query] = params[:query]
      options[:start] = _parse_time(params[:start]) if params[:start]
      options[:end] = _parse_time(params[:end]) if params[:end]
      options[:duration] = params[:duration].to_i if params[:duration]
      
      url = client.graph_snapshot_url(options)

      redirect url, 302
    end

    private
    def _parse_time(str)
      if /^\d+$/ =~ str
        Time.at(str.to_i)
      else
        time = Chronic.parse(str)
        return time if time
        raise Error, "Cannot parse time (#{str})"
      end
    end
  end
end

