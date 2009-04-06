class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :type
      t.integer :created_by_id
      t.integer :assignee_id
      t.integer :house_id
      t.string  :flat           # номер квартиры / офиса
      t.integer :status_id

      t.integer :contact_type
      t.string  :contact_name
      t.text    :contact_info

      t.text    :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
