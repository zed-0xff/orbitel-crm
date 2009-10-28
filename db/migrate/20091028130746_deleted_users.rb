class DeletedUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :deleted, :boolean
  end

  def self.down
    remove_column :users, :deleted
  end
end
