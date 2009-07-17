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

  def add_alias new_alias
    self.aliases = ([''] + self.aliases.to_s.split(':') + [new_alias]).uniq.sort.join(':') + ':'
  end

  def remove_alias old_alias
    self.aliases = ([''] + self.aliases.split(':').delete_if{ |a| a==old_alias }).uniq.sort.join(':') + ':'
    self.aliases = nil if self.aliases == ':'
    self.aliases
  end

  def self.find_or_initialize_by_name name
    name.gsub!('ул.','')
    name.strip!
    find_by_name(name) || Street.new(:name => name)
  end

  def self.smart_find name
    # simple find
    r = self.find_by_name name
    return r if r

    # some simple strips
    name = name.mb_chars.downcase.to_s.gsub('ул.','').strip.
      sub(/^ул /,'').strip.
      gsub(/ {2,}/,' ').
      gsub(' .','.').
      gsub('. ','.').
      gsub(/^[-,.;:]|[-,.;:]$/,'').strip
    r = self.find_by_name name
    return r if r

    # two words in reverse order
    a = name.split(' ')
    return r if (a.size == 2) && (r = self.find_by_name(a.reverse.join(' ')))

    # partial match
    r = self.all :conditions => ['name LIKE ?',"%#{name}%"], :limit => 2
    return r.first if r.size == 1

    # aliases match
    r = self.all(
      :conditions => [
        'aliases LIKE ?', 
        "%:#{name}:%"
      ], 
      :limit => 2
    )
    return r.first if r.size == 1

    # partial shortened match
    if name[/[.-]+/]
      a = name.split(/[.-]+/,2)
      r = self.all(
        :conditions => [
          'name LIKE ? OR name LIKE ? OR name LIKE ?', 
          "#{a[0]}% #{a[1]}",
          "#{a[0]}%-#{a[1]}",
          "#{a[1]} #{a[0]}%",
        ], 
        :limit => 2
      )
      return r.first if r.size == 1
    end

    nil
  end
end
