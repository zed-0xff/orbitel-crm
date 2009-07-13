class Phone < ActiveRecord::Base
  belongs_to :customer

  def humanize
    # 8-909-724-7755
    # 8 3522 44-22-55
    # 8 495 543-33-44
  end

  def self.from_string_or_array src
    soa2numbers(src).map{ |num| Phone.new(:number => num) }
  end

  # string_or_array to numbers
  def self.soa2numbers src
    numbers = []
    src = [src] unless src.is_a?(Array)
    src.each do |ph1|
      ph1.to_s.strip.split(/[,;а-яА-Я]/u).uniq.
        delete_if{|n| n.blank?}.compact.
        each do |ph2|
          numbers << canonicalize(ph2)
      end
    end
    numbers.uniq.compact
  end

  def self.canonicalize number
    number = number.to_s.gsub(/[^0-9+]/,'')
    return nil if number.blank?
    # 89097247755
    # 83522442255
    # 84955433344
    number = "8#{number}" if number.size == 10 && number.first != '8'
    number[0..1] = '8' if number[0..1] == '+7'
    if number.size < 11
      number = '835222'[0..(10-number.size)] + number
    end
    number.to_i
  end
end
