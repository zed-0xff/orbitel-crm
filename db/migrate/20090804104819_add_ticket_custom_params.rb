class AddTicketCustomParams < ActiveRecord::Migration
  def self.up
    add_column :tickets, :custom_info, :text
  end

  def self.down
    remove_column :tickets, :custom_info
  end
end
