class AddCustomersNodeId < ActiveRecord::Migration
  def self.up
    add_column :customers, :node_id, :integer
    add_index :customers, :node_id
  end

  def self.down
    remove_column :customers, :node_id
  end
end
