require 'datadog_proxy'
require 'dogapi'
require 'timeout'
require 'net/https'

module DatadogProxy
  class DatadogClient
    class Error < StandardError; end

    def initialize(api_key, app_key)
      @client = Dogapi::Client.new(api_key, app_key)
    end

    def graph_snapshot_url(options)
      _graph_snapshot_url(options)
    end

    private

    def _graph_snapshot_url(options)
      query = options[:query]
      raise Error, "query is not supplied" unless query

      case
      when options[:start] && options[:end]
        start_time = options[:start]
        end_time = options[:end]
      when options[:start] && options[:duration]
        start_time = options[:start]
        end_time = start_time + options[:duration]
      when options[:end] && options[:duration]
        end_time = options[:end]
        start_time = end_time - options[:duration]
      else
        raise Error, "Two of start, end and duration are necessary at least."
      end

      response = @client.graph_snapshot(
        query, start_time.to_i, end_time.to_i
      )

      if response[0] != '200'
        # error
        raise Error, "Failed to get a snapshot."
      end

      snapshot_url = response[1]['snapshot_url']
      timeout(10) do
        _wait_for_generating(snapshot_url)
      end

      snapshot_url
    end

    def _wait_for_generating(url)
      while true
        uri = URI.parse(url)
        req = Net::HTTP::Head.new(uri.path)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        res = http.start do
          http.request(req)
        end
        if res.code == '200' && res["Content-Length"].to_i > 1024
          return
        end
        sleep 1
      end
    end
  end
end


