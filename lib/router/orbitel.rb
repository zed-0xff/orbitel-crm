require 'net/http'
require 'yaml'

class Router::Orbitel < Router
  cattr_accessor %w'ip_info_url create_user_url'

  # fetch ip info (vlan, mac address, etc)
  def self.ip_info ip
    fetch_yaml_url(ip_info_url.sub('IP',ip.to_s))
  end

  # создать юзера на роутере
  def self.create_user! vlan, ip, comment
    h = {}
    h[:vlan] = vlan
    h[:ip]   = ip
    h[:fio]  = comment
    h[:ru]  = 'ру' # для автоопределения кодировки на стороне сервера
    r = Net::HTTP.post_form( URI.parse(create_user_url), h)
    r.body
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
