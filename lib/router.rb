class Router
  cattr_accessor :ip_info_url

  # fetch ip info (vlan, mac address, etc)
  def self.ip_info ip
    fetch_yaml_url(ip_info_url.sub('IP',ip.to_s))
  end

  # ping ip address to test for lost packets
  def self.ping ip
  end

  # menu items to show in Customer -> [router part]
  # пункты меню, которые показываются в просмотре Абонента -> "Данные роутера"
  # (надо нажать на серенький плюсик)
  def self.menu_items
    [{
      :name => 'tcpdump',
      :href => 'tcpdump://{IP}'
    },{
      :name => 'iftop',
      :href => 'iftop://{IP}'
    }]
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
