class Phone < ActiveRecord::Base
  belongs_to :customer

  def humanize
    Phone.humanize number
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

  def self.humanize number
    s = number.to_s

    if s.size == 6
      return s[0..1] + '-' + s[2..3] + '-' + s[4..5]
    end

    return s if s.size != 11

    if s.starts_with?'89'
      # 89097247755 -> 8-909-724-7755
      "8-#{s[1..3]}-#{s[4..6]}-#{s[7..-1]}"
    elsif s.starts_with?'83522'
      # 83522442255 -> 44-22-55
      s[5..6] + '-' + s[7..8] + '-' + s[9..10]
    elsif s.starts_with?('8')
      if s[4..4] == '2'
        # 83512433344 -> (3512) 43-33-44
        '(' + s[1..4] + ') ' + s[5..6] + '-' + s[7..8] + '-' + s[9..10]
      else
        # 84955433344 -> (495) 543-33-44
        '(' + s[1..3] + ') ' + s[4..6] + '-' + s[7..8] + '-' + s[9..10]
      end
    else
      s
    end
    
  end
end
