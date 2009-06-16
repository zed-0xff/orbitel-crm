class CreateTicketHistoryEntries < ActiveRecord::Migration
  def self.up
    create_table :ticket_history_entries do |t|
      t.belongs_to :ticket, :null => false
      t.datetime :created_at
      t.belongs_to :user, :null => false
      t.integer :old_status
      t.integer :new_status
      t.text :comment
    end

    add_index :ticket_history_entries, [:ticket_id, :created_at]
  end

  def self.down
    drop_table :ticket_history_entries
  end
end
