class CreateHouses < ActiveRecord::Migration
  def self.up
    create_table :houses do |t|
      t.integer :street_id
      t.string :number
    end

    add_index :houses, :street_id
  end

  def self.down
    drop_table :houses
  end
end
