class AddVlanToHouses < ActiveRecord::Migration
  def self.up
    add_column :houses, :vlan, :integer
  end

  def self.down
    remove_column :houses, :vlan
  end
end
