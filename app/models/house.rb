class House < ActiveRecord::Base
  belongs_to :street
  has_many :tickets

  accepts_nested_attributes_for :street

  validates_presence_of :number, :street
  validates_associated  :street

  # статусы для возможностей подключения:
  ST_YES            =  1 # подключаем без всяких ограничений
  ST_MINOR_PROBLEMS = 10 # вообще подключаем, но сейчас есть небольшие проблемы
  ST_MAJOR_PROBLEMS = 30 # вообще подключали, но сейчас есть серьёзные проблемы
  ST_IN_PLANS       = 40 # пока нет возможности, но возможность планируется
  ST_NO             = 50 # нет технической возможности

  def coords
    (x && y) ? [x,y] : nil
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
