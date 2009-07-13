class Radius::Call < ActiveRecord::Base
  establish_connection "radius_#{RAILS_ENV}"
  set_table_name 'radacct'
  set_primary_key 'radacctid'
  default_scope :order => "acctstarttime, acctstoptime"

  def caller
    callingstationid ? callingstationid.to_i : nil
  end

  def start_time
    self.acctstarttime
  end

  def end_time
    self.acctstoptime
  end

  # from 'caller' (source number) field now
  # because destination number is always our support phone number
  def customer
    caller ? Customer.find_by_phone(caller) : nil
  end
end
