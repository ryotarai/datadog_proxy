require 'spec_helper'

describe 'Datadog Proxy' do
  include Rack::Test::Methods

  def app
    DatadogProxy::App
  end

  let(:client) do
    double(:client)
  end

  before do
    allow_any_instance_of(DatadogProxy::App).to receive(:client).and_return(client)
  end

  describe "GET /" do
    it "returns docuement in markdown" do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to match(/^# Datadog Proxy/)
    end
  end

  describe "GET /graphs/snapshot" do
    context "with query, start and end" do
      it "returns the url of a graph" do
        expect(client).to receive(:graph_snapshot_url).with(
          {
            query: 'query',
            start: Time.at(0),
            end: Time.at(1024),
          }
        ).and_return('http://example.com/graph')

        get '/graphs/snapshot', query: "query", start: "0", end: "1024"
        expect(last_response.status).to eq(302)
        expect(last_response.header['Location']).to eq('http://example.com/graph')
      end
    end
  end
end
