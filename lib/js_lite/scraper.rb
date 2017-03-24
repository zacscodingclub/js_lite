# get(uri, parameters = [], referer = nil, headers = {}) { |page| ... }
require 'pry'
module JsLite
  class Scraper
    attr_reader :store, :rank, :category, :sales

    ENDPOINT = 'https://junglescoutpro.herokuapp.com/api/v1/est_sales'

    def initialize(rank, category, store="us")
    	@store = store
      @rank = rank.to_s
      @category = category

      @agent = mech_setup
      @sales = parse_result
    end

    def self.create(rank, category)
      instance = new(rank, category)
      instance.sales
    end

    def query_params
      {
             "store" => @store,
             "rank"  => @rank,
          "category" => @category.values[0]
      }
    end

    def headers
      {
                 "Accept" => "application/json, text/javascript, */*; q=0.01",
        "Accept-Encoding" => "gzip, deflate, sdch, br",
        "Accept-Language" => "en-US,en;q=0.8,de;q=0.6",
             "Connection" => "keep-alive",
                   "Host" => "junglescoutpro.herokuapp.com",
                 "Origin" => "https://www.junglescout.com",
                "Referer" => "https://www.junglescout.com/estimator/"
      }
    end

    def mech_setup
      Mechanize.new do |agent|
        agent.user_agent = Mechanize::AGENT_ALIASES.keys.sample
        agent.pre_connect_hooks << lambda do |agent, request|
          request['X-Requested-With'] = 'XMLHttpRequest'
        end
      end
    end

    def get
      @agent.get(ENDPOINT, query_params, headers["Referer"], headers)
    end

    def parse_result
      response = get
      json_response = JSON.parse(response.body)
      json_response["estSalesResult"]
    end
  end
end
