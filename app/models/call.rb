# this model is mostly for call archive purposes
class Call < ActiveRecord::Base
  belongs_to :customer
  default_scope :order => "start_time DESC"

  # avoid duplicate entries on wrong sync
  validates_uniqueness_of :phone_number, :scope => [:start_time, :duration]
end
