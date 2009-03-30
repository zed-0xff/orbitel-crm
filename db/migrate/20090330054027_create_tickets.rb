class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :type
      t.integer :created_by_id
      t.integer :assignee_id
      t.integer :house_id
      t.integer :status_id
      t.text :description
      t.text :contact

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
