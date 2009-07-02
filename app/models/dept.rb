# Dept = Department = Отдел
class Dept < ActiveRecord::Base
  default_scope :order => 'name'

  has_many :users

  validates_presence_of :name
  validates_uniqueness_of :name, :handle
end
