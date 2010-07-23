class AddTickesParentId < ActiveRecord::Migration
  def self.up
    add_column :tickets, :parent_id, :integer
    add_index :tickets, :parent_id
  end

  def self.down
    remove_column :tickets, :parent_id
  end
end
