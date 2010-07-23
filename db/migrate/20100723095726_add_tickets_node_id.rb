class AddTicketsNodeId < ActiveRecord::Migration
  def self.up
    add_column :tickets, :node_id, :integer
    add_index :tickets, :node_id
  end

  def self.down
    remove_column :tickets, :node_id
  end
end
