class NotAllowHousesWithNullStreetId < ActiveRecord::Migration
  def self.up
    change_column_null :houses, :street_id, false
  end

  def self.down
    change_column_null :houses, :street_id, true
  end
end
