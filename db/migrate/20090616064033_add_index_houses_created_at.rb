class AddIndexHousesCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :houses, :created_at
  end

  def self.down
    remove_index :houses, :created_at
  end
end
