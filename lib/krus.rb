class Krus
  cattr_accessor :customers_url
  cattr_accessor :user_info_url

  def self.fetch_customers
    fetch_yaml_url customers_url
  end

  def self.user_info uid
    fetch_yaml_url(user_info_url.sub('UID',uid.to_s))
  end

  private

  def self.fetch_yaml_url url
    url = URI.parse( url )
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 600
      http.get(url.request_uri)
    }

    YAML::load( res.body )
  end
end
