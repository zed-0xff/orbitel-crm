class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :external_id
      t.integer :parent_id
      t.string :nodetype

      t.timestamps
    end
    add_index :nodes, :parent_id
  end

  def self.down
    drop_table :nodes
  end
end
