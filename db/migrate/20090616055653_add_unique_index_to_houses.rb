class AddUniqueIndexToHouses < ActiveRecord::Migration
  def self.up
    add_index :houses, [:street_id, :number], :unique => true
  end

  def self.down
    remove_index :houses, [:street_id, :number]
  end
end
