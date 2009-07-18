class CreateCalls < ActiveRecord::Migration
  def self.up
    create_table :calls do |t|
      t.integer    :phone_number, :limit => 8, :null => false
      t.datetime   :start_time, :null => false
      t.integer    :duration, :limit => 2
      t.belongs_to :customer
    end

    add_index :calls, [:customer_id, :start_time]
    add_index :calls, :phone_number
  end

  def self.down
    drop_table :calls
  end
end
