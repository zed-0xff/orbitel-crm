class Node < ActiveRecord::Base
#  validates_uniqueness_of :name
  validates_presence_of :name
  belongs_to :parent, :class_name => 'Node'
  has_many :subnodes, :class_name => 'Node', :foreign_key => 'parent_id'

  has_many :customers
  has_many :tickets
end
