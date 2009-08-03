class AddCustomerIdToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :customer_id, :integer
    add_index  :tickets, :customer_id
  end

  def self.down
    remove_column :tickets, :customer_id
  end
end
