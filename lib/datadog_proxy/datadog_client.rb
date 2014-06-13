require 'datadog_proxy'
require 'dogapi'

module DatadogProxy
  class DatadogClient
    class Error < StandardError; end

    def initialize(api_key, app_key)
      @client = Dogapi::Client.new(api_key, app_key)
      @graph_snapshot_url_cache = {}
    end

    def graph_snapshot_url(options)
      # TODO: cap cache size or use external storage like memcached
      @graph_snapshot_url_cache[options.hash] ||= _graph_snapshot_url(options)

      # Append time to avoid the graph is cached.
      "#{@graph_snapshot_url_cache[options.hash]}?#{Time.now.to_i}"
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

      response[1]['snapshot_url']
    end
  end
end


