class TicketRenameStatusIdToStatus < ActiveRecord::Migration
  def self.up
    rename_column :tickets, :status_id, :status
  end

  def self.down
    rename_column :tickets, :status, :status_id
  end
end
