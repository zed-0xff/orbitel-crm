class CreateHouses < ActiveRecord::Migration
  def self.up
    create_table :houses do |t|
      t.integer :street_id
      t.string  :number
      t.integer :x              # абсцисса ;)
      t.integer :y              # ордината ;)
      t.integer :inet_status
      t.integer :phone_status
      t.integer :video_status
    end

    add_index :houses, :street_id
  end

  def self.down
    drop_table :houses
  end
end
