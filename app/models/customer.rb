class Customer < ActiveRecord::Base
  before_save :cleanup_name

  belongs_to :house

  has_many :calls
  has_many :tickets

  has_many :phones, :dependent => :delete_all do
    def add phone
      phones = Phone.from_string_or_array(phone)
      phones.each do |ph|
        next unless ph.valid?
        next if proxy_owner.phones.map(&:number).include?(ph.number)
        proxy_owner.phones << ph
      end
    end
  end

  def initialize *args
    if args.first.is_a?(Hash)
      phones   = args.first.delete(:phones)
      phones ||= args.first.delete(:phone).to_a
      if phones.any?
        args.first[:phones] = Phone.from_string_or_array(phones)
      end
    end
    super
  end

  def address
    if house
      "#{house.street.try(:name)} #{house.number}" + (flat.blank? ? '' : "-#{flat}")
    else
      nil
    end
  end

  def name_with_address
    a = self.address
    "#{self.name}" + (a ? " (#{a})" : '')
  end

  def address= addr
    a = addr
    if a['секц']
      a = [a[0..(a.index('секц')-1)], a[(a.index('секц'))..-1]]
    else
      a = addr.split /офис|оф\.| оф | кв |кв\.?|квартира| каб |каб\.|кабинет|комн?\.|комната/ui
    end
    if a.size == 1
      a = addr.split '-'
    end
    if a.size > 2
      a = [a[0..-2].join('-'), a[-1]]
    end
    self.house = House.from_string(a[0].strip)
    self.flat = a[1].strip if a[1]
  end

  def billing_info
    return nil unless self.external_id
    r = Krus.user_info(self.external_id)
    if r && r[:status] && r[:status].is_a?(Hash)
      Rails.cache.write(
        "customer.#{self.id}.ips", 
        r[:status].keys.sort_by{ |ip| ip.split('.').map(&:to_i) },
        :expires_in => 8.hours
      )
    end
    r
  end

  def billing_toggle_inet state
    return false unless self.external_id
    r = Krus.user_toggle_inet(self.external_id, state)
    if r && r[:status] && r[:status].is_a?(Hash)
      Rails.cache.write(
        "customer.#{self.id}.ips", 
        r[:status].keys.sort_by{ |ip| ip.split('.').map(&:to_i) },
        :expires_in => 8.hours
      )
    end
    r
  end

  def router_info
    ips = self.ips
    return nil unless ips
    h = ActiveSupport::OrderedHash.new
    ips.each do |ip|
      h[ip] = Router.ip_info(ip)
    end
    h
  end

  def ips
    ips = Rails.cache.read "customer.#{self.id}.ips"
    unless ips
      billing_info
      ips = Rails.cache.read "customer.#{self.id}.ips"
    end
    ips
  end

  def self.find_by_phone phone_number
    Phone.find_by_number(Phone.canonicalize(phone_number)).try(:customer)
  end

  def self.find_by_name_and_address nameaddr
    if nameaddr =~ /^(.+)\(([^()]+)\)$/
      name = $1.strip
      addr = $2.strip
      Customer.all(:conditions => {:name => name}).each do |c|
        return c if c.address == addr
      end
    end
    # last chanse
    return Customer.find_by_name(nameaddr)
  end

  def self.cleanup_name name
    name.strip!
    name.gsub!(/ {2,}/,' ')
    name.gsub!(/[иИ]ндивидуальный [Пп]редприниматель/ui,'ИП')
    name.gsub!(/[гГ]осударственное [оО](бластное|бразовательное) [уУ]чреждение/ui,'ГОУ')
    name.gsub!(/[гГ]осударственное [уУ]чреждение/ui,'ГУ')
    name.gsub!(/[сС]реднего [пП]рофессионального [оО]бразования/ui,'СПО')
    name.gsub!(/[Зз3]акрытое [аА]кционерное [оО]б[шщ]ество/ui,'ЗАО')
    name.gsub!(/[оО]ткрытое [аА]кционерное [оО]б[шщ]ество/ui,'ОАО')
    name.gsub!(/[оО]б[шщ]ество [сС] [оО]граниченн?ой [оО]тветственн?остью/ui,'ООО')
    name.gsub!(/[Мм]униципальное [дД]ошкольное [оО]бразовательное [уУ]чреждение/ui,'МДОУ')
    name.gsub!(/[Мм]униципальное [уУ]чреждение/ui,'МУ')
    name.gsub!(/Федеральное [гГ]осударственное [уУ]нитарное [Пп]редприятие/ui,'ФГУП')
    name.gsub!(/Федеральное [гГ]осударственное [уУ]чреждение [Зз3]дравоохранения/ui,'ФГУЗ')
    name.gsub!(/[гГ]\. [Кк]урган/ui,'г.Курган')
    name.gsub!(/[«»]/u,'"')
    name.
      tr("`'",'""""').
      sub(/^"(.+)"$/,'\1').
      strip
  end

  private

  def cleanup_name
    self.name = self.class.cleanup_name(self.name) if self.name
  end
end
