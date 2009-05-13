class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :type
      t.belongs_to :created_by
      t.belongs_to :assignee
      t.belongs_to :house
      t.string  :flat           # номер квартиры / офиса
      t.belongs_to :status

      t.integer :contact_type
      t.string  :contact_name
      t.text    :contact_info

      t.text    :notes

      t.timestamps
    end

    add_index :tickets, :created_at
    add_index :tickets, :assignee_id
  end

  def self.down
    drop_table :tickets
  end
end
