require 'cgi'
require 'yaml'

class Billing::Krus < Billing
  cattr_accessor :host, :port, :key

  def self.fetch_users
    fetch_yaml_url "report/users.yaml?no_zombies=1"
  end

  def self.fetch_tariffs
    fetch_yaml_url "tarifs.yaml"
  end

  def self.user_info uid
    #  ---
    #  :user_id: 1234
    #  :tarif_red: true
    #  :tarif_id: 188
    #  :bandwidth:
    #  :tarif_change_date: 2009-05-01
    #  :bal: 123.90
    #  :status:
    #    192.168.18.16:
    #      :red: true
    #      :name: "Выключен"
    #  :name: "Иванов Иван Иванович"
    #  :address: "ул. К. Мяготина 14-121"
    #  :lic_schet: 36006102
    #  :tarif: "Название Тарифа"
    #  :traf_report: {}
    #  :bal_red: true

    fetch_yaml_url "user_info/#{uid.to_i}.yaml"
  end

  def self.user_traf_info uid, args={}
    url = "user_traf_info/#{uid.to_i}.yaml"
    if args.any?
      url += "?" + args.map{ |k,v| "#{k}=#{v}" }.join('&')
    end
    r = fetch_yaml_url url
    #(r.is_a?(Hash) && r.key?(:traf)) ? r[:traf] : r
    r
  end

  def self.ip_info ip
    fetch_yaml_url "ip_info/#{ip}.yaml"
  end

  # Включить/выключить юзеру доступ в инет
  # возвращает то же, что и в user_info
  def self.user_toggle_inet uid, state
    st = state ? 'on' : 'off'
    fetch_yaml_url "user_info/#{uid.to_i}.yaml?toggle=#{st}&key=#{key}"
  end

  # Коррекция баланса юзера
  # возвращает то же, что и в user_info
  def self.user_correct_balance uid, amount, comment
    fetch_yaml_url(
      "payments/correct_balance/#{uid.to_i}" +
        "?amount=#{CGI.escape(amount)}" +
        "&comment=#{CGI.escape(comment)}" +
        "&key=#{CGI.escape(key)}",
      true
    )
  end

  # создать новое подключение
  def self.user_create_connection uid, tarif_id, ip
    fetch_url(
      "connections/create" +
        "?user_id=#{uid.to_i}" +
        "&tarif_id=#{tarif_id.to_i}" +
        "&ip=#{CGI.escape(ip)}" +
        "&key=#{CGI.escape(key)}"
    )
  end

  private

  def self.fetch_url url, follow_redirect = false
    url = URI.parse "http://#{host}:#{port}/#{url}"
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 600
      http.get(url.request_uri)
    }

    if RAILS_ENV == 'development'
      Rails.logger.info("KRUS status:   #{res.code} #{res.msg}")
      Rails.logger.info("KRUS redirect: #{res['location']}") unless res['location'].blank?
      Rails.logger.info("KRUS body:     #{res.body}")
    end

    if follow_redirect && res.is_a?(Net::HTTPRedirection)
      return fetch_url(
        res['location'].
        sub("http://#{host}:#{port}/",''). # make location relative (DIRTY!)
        sub("http://#{host}/",'')
      )
    end

    res.body
  end

  def self.fetch_yaml_url url, follow_redirect = false
    YAML::load fetch_url(url,follow_redirect)
  end
end
