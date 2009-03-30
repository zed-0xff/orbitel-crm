class Ticket < ActiveRecord::Base
  belongs_to :house

  accepts_nested_attributes_for :house
end
