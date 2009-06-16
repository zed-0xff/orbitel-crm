class AddUniqueIndexToStreets < ActiveRecord::Migration
  def self.up
    add_index :streets, :name, :unique => true
  end

  def self.down
    remove_index :streets, :name
  end
end
