class House < ActiveRecord::Base
  belongs_to :street
  has_many :tickets

  validates_presence_of :number, :street

  # статусы для возможностей подключения:
  ST_YES            =  1 # подключаем без всяких ограничений
  ST_MINOR_PROBLEMS = 10 # вообще подключаем, но сейчас есть небольшие проблемы
  ST_MAJOR_PROBLEMS = 30 # вообще подключали, но сейчас есть серьёзные проблемы
  ST_IN_PLANS       = 40 # пока нет возможности, но возможность планируется
  ST_NO             = 50 # нет технической возможности
end
