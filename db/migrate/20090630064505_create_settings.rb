class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :key, :null => false
      t.text :value
    end

    add_index :settings, :key, :unique => true
  end

  def self.down
    drop_table :settings
  end
end
