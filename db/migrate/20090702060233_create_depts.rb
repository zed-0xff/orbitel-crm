class CreateDepts < ActiveRecord::Migration
  def self.up
    create_table :depts do |t|
      t.string :name, :null => false
      t.string :handle
    end

    add_index :depts, :handle, :unique => true

    add_column :users, :dept_id, :integer
  end

  def self.down
    remove_column :users, :dept_id
    drop_table :depts
  end
end
