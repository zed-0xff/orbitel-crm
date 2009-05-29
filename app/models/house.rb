class House < ActiveRecord::Base
  belongs_to :street
  has_many :tickets

  accepts_nested_attributes_for :street

  validates_presence_of :number, :street
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

  def self.find_or_initialize_by_street_and_number street_name, number
    street = Street.find_or_initialize_by_name street_name
    house = if street.new_record?
      House.new(
        :number => number,
        :street => street
      )
    else
      House.find_or_initialize_by_street_id_and_number(
        street.id,
        number
      )
    end
  end
end
