class AddPriorityToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :priority, :integer, :default => 0
  end

  def self.down
    remove_column :tickets, :priority
  end
end
