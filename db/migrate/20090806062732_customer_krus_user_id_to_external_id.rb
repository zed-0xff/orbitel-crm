class CustomerKrusUserIdToExternalId < ActiveRecord::Migration
  def self.up
    rename_column :customers, :krus_user_id, :external_id
  end

  def self.down
    rename_column :customers, :external_id, :krus_user_id
  end
end
