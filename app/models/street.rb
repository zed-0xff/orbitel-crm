class Street < ActiveRecord::Base
  validates_presence_of   :name
  validates_length_of     :name, :minimum => 2
  validates_uniqueness_of :name

  has_many :houses

  before_save :capitalize_name

  def capitalize_name
    self.name = self.name.mb_chars.titleize.to_s
  end
end
