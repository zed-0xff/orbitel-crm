class Customer < ActiveRecord::Base
  before_save :cleanup_name

  belongs_to :house

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

  def address= addr
    a = addr
    if a['секц']
      a = [a[0..(a.index('секц')-1)], a[(a.index('секц'))..-1]]
    else
      a = addr.split /офис|оф\.|кв\.?|квартира|каб\.|кабинет|комн?\.|комната/ui
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

  def self.find_by_phone phone_number
    Phone.find_by_number(Phone.canonicalize(phone_number)).try(:customer)
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
