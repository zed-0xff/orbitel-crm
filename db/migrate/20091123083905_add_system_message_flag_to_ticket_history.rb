class AddSystemMessageFlagToTicketHistory < ActiveRecord::Migration
  def self.up
    add_column :ticket_history_entries, :system_message, :boolean
  end

  def self.down
    remove_column :ticket_history_entries, :system_message
  end
end
