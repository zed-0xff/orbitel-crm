class Krus
  cattr_accessor :host, :port

  def self.fetch_customers
    fetch_yaml_url "report/users.yaml?no_zombies=1"
  end

  def self.fetch_tariffs
    fetch_yaml_url "tarifs.yaml"
  end

  def self.user_info uid
    fetch_yaml_url "user_info/#{uid}.yaml"
  end

  private

  def self.fetch_yaml_url url
    url = URI.parse "http://#{host}:#{port}/#{url}"
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 600
      http.get(url.request_uri)
    }

    YAML::load( res.body )
  end
end
