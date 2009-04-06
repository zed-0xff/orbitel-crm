class Ticket < ActiveRecord::Base
  belongs_to :house

  accepts_nested_attributes_for :house

  CONTACT_TYPE_UR  = 1
  CONTACT_TYPE_FIZ = 2
end
