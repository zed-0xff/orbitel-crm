class AddTitleToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :title, :string
  end

  def self.down
    remove_column :tickets, :title
  end
end
