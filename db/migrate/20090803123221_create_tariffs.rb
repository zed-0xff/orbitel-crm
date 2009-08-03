class CreateTariffs < ActiveRecord::Migration
  def self.up
    create_table :tariffs do |t|
      t.string  :name, :null => false
      t.boolean :avail_fiz
      t.boolean :avail_ur
      t.integer :external_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tariffs
  end
end
