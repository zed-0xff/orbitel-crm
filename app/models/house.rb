class House < ActiveRecord::Base
  belongs_to :street
  has_many :tickets
end
