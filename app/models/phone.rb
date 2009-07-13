class Phone < ActiveRecord::Base
  belongs_to :customer

  def self.from_array_or_string src
    numbers = []
    src.to_a.each do |ph1|
      ph1.to_s.strip.split(/[,;]/).each do |ph2|
        numbers << canonicalize(ph2)
      end
    end
    numbers.uniq.compact.map{ |num| Phone.new(:number => num) }
  end

  def self.canonicalize number
    number = number.to_s.delete('-() ')
    # 89097247755  8-909-724-7755
    # 83522442255  8 3522 44-22-55
    # 84955433344  8 495 543-33-44
    number = "8#{number}" if number.size == 10 && number.first != '8'
    number[0..1] = '8' if number[0..1] == '+7'
    if number.size != 11
      number = '835222'[0..(10-number.size)] + number
    end
    number.to_i
  end
end
