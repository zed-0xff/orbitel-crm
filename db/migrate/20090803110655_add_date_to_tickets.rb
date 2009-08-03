class AddDateToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :date, :date
  end

  def self.down
    remove_column :tickets, :date
  end
end
