class Krus
  cattr_accessor :customers_url

  def self.fetch_customers
    url = URI.parse( customers_url )
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 600
      http.get(url.request_uri)
    }

    YAML::load( res.body )
  end
end
