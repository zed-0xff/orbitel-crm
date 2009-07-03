# Dept = Department = Отдел
class Dept < ActiveRecord::Base
  default_scope :order => 'name'

  has_many :users
  has_many :tickets

  validates_presence_of :name
  validates_uniqueness_of :name, :handle

  def self.[] handle
    find_by_handle(handle.to_s)
  end
end
