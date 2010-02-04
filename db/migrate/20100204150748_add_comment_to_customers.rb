class AddCommentToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :comment, :text
  end

  def self.down
    remove_column :customers, :comment
  end
end
