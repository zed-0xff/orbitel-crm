class Phone < ActiveRecord::Base
  belongs_to :customer

  def self.from_array_or_string src
    numbers = []
    src.to_a.each do |ph1|
      ph1.to_s.strip.split(/[,;]/).each do |ph2|
        numbers << ph2.tr('()-','').to_i
      end
    end
    numbers.uniq.map{ |num| Phone.new(:number => num) }
  end
end
