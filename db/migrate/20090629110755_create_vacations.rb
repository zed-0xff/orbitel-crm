class CreateVacations < ActiveRecord::Migration
  def self.up
    create_table :vacations do |t|
      t.belongs_to :user
      t.date :start_date, :null => false
      t.date :end_date, :null => false
    end
    add_index :vacations, [:start_date, :end_date]
  end

  def self.down
    drop_table :vacations
  end
end
