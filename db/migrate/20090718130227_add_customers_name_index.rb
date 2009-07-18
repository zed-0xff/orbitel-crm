class AddCustomersNameIndex < ActiveRecord::Migration
  def self.up
    add_index :customers, :name
  end

  def self.down
    remove_index :customers, :name
  end
end
