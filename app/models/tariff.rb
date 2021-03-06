class Tariff < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :external_id

  default_scope :order => 'name'
end
