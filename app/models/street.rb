class Street < ActiveRecord::Base
  validates_presence_of   :name
  validates_length_of     :name, :minimum => 2
  validates_uniqueness_of :name

  has_many :houses

  before_save :fix_name
  before_save :capitalize_name

  def capitalize_name
    if self.name == self.name.mb_chars.downcase.to_s
      self.name = self.name.mb_chars.capitalize.to_s
    end
  end

  def fix_name
    self.name.strip!
    self.name.gsub!(/^[Уу][Лл]\./,'')
    self.name.strip!
  end

  # carefully reassign any houses from this street to other,
  # and then destroy this street.
  # used for manual fixing of occasionally created duplicate streets.
  def replace_with! other_street
    self.houses.each do |house|
      if other_house = House.find_by_street_id_and_number(other_street.id, house.number)
        house.replace_with! other_house
      else
        house.street = other_street
        house.save!
      end
    end
    if self.houses.reload.size == 0
      self.destroy
      true
    else
      false
    end
  end

  def self.find_or_initialize_by_name name
    name.gsub!('ул.','')
    name.strip!
    find_by_name(name) || Street.new(:name => name)
  end
end
