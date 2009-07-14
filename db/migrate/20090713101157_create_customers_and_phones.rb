class CreateCustomersAndPhones < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string   :name, :null => false
      t.string   :flat
      t.integer  :karma

      t.integer  :krus_user_id
      t.datetime :krus_sync_date

      t.timestamps
    end

    add_index :customers, :krus_user_id

    create_table :phones do |t|
      t.belongs_to :customer
      t.integer :number, :limit => 8, :null => false
    end

    add_index :phones, :number, :unique => true
    add_index :phones, :customer_id
  end

  def self.down
    drop_table :phones
    drop_table :customers
  end
end
