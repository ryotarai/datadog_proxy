require 'datadog_proxy'
require 'sinatra'

module DatadogProxy
  class App < Sinatra::Application
    def initialize(*args)
      super(*args)
    end

    def client
      p :hello
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
      options = {}
      options[:query] = params[:query]
      options[:start] = Time.at(params[:start].to_i) if params[:start]
      options[:end] = Time.at(params[:end].to_i) if params[:end]
      options[:duration] = params[:duration].to_i if params[:duration]

      url = client.graph_snapshot_url(options)

      redirect url, 302
    end
  end
end

