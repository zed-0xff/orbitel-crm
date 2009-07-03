class AddDeptToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :dept_id, :integer
  end

  def self.down
    remove_column :tickets, :dept_id
  end
end
