class House < ActiveRecord::Base
  belongs_to :street
  has_many :tickets
  has_many :customers

  accepts_nested_attributes_for :street

  validates_presence_of :number, :message => '^Не указан номер дома'
  validates_presence_of :street, :message => '^Не указана улица'
  validates_associated  :street

  validates_uniqueness_of :number, :scope => :street_id

  validates_inclusion_of :vlan, :in => 1..4095, :allow_nil => true, :message => "must be in range 1..4095"

  # статусы для возможностей подключения:
  ST_YES            =  1 # подключаем без всяких ограничений
  ST_MINOR_PROBLEMS = 10 # вообще подключаем, но сейчас есть небольшие проблемы
  ST_MAJOR_PROBLEMS = 30 # вообще подключали, но сейчас есть серьёзные проблемы
  ST_IN_PLANS       = 40 # пока нет возможности, но возможность планируется
  ST_NO             = 50 # нет технической возможности

  STATUSES = [1, 10, 30, 40, 50]

  def coords
    (x && y) ? [x,y] : nil
  end

  def initialize *args
    if args.first.is_a?(Hash) && args.first[:street].is_a?(String)
      args.first[:street] = Street.find_or_initialize_by_name args.first[:street]
    end
    super *args
  end

  # carefully reassign any tickets from this house to other
  # and then destroy this house.
  # used for manual fixing of occasionally created duplicate houses/streets
  def replace_with! other_house
    if self.inet_status && !other_house.inet_status
      other_house.inet_status = self.inet_status
    end
    if self.comment && !other_house.comment
      other_house.comment = self.comment
    end
    self.tickets.each do |ticket|
      ticket.house = other_house
      ticket.save!
    end
    if Customer.table_exists?
      self.customers.each do |customer|
        customer.house = other_house
        customer.save!
      end
    end
    if self.tickets.reload.size == 0 && (!Customer.table_exists? || self.customers.reload.size == 0)
      self.destroy
      true
    else
      false
    end
  end

  def self.find_or_initialize_by_street_and_number street, number
    street = Street.smart_find(street) unless street.is_a?(Street)
    house = if street
      House.find_or_initialize_by_street_id_and_number(
        street.id,
        number
      )
    else
      House.new(
        :number => number
      )
    end
  end

  def self.from_string addr
#    puts "[.] #{addr}"
    addr.sub! /[уУ][лЛ]\./,''
    addr.sub! 'пр.',''
    addr.sub! /6400\d\d/,'' # remove index/zip
    addr.strip!
    addr.sub!(/ {2,}/, ' ')
    addr.sub! '. ','.'
    addr.sub! 'г.Курган',''
    addr.sub! /^[гГ]\./,''
    addr.sub! /^[,;. ]+|[,;. ]+$/, ''
#    puts "[.] #{addr}"
    a = addr.split(',').map(&:strip)
    if a.size == 1
      a = addr.reverse.split(' ',2).reverse.map(&:reverse).map(&:strip)
    end
    num = a[1].to_s.mb_chars.downcase.to_s
    num.gsub! /\(.*\)/, ''
    num.gsub! /[()].*/, ''
    num.strip!
    num.sub! 'дом',''
    num.sub! /^д/,''
    num.gsub! /^[-,.;]|[-,.;]$/,''
    num.strip!
    num.sub! /^(\d+)[ -]([^\d])$/, '\1\2'
    num = num.gsub('i','I').gsub('v','V') # римские цифры
    num = nil unless num[/\d/] # number must contain at least one digit
    num = nil if num.blank?
    find_or_initialize_by_street_and_number a[0], num
  end
end
