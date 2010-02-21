class CustomerKrusSyncDateToBillingSyncDate < ActiveRecord::Migration
  def self.up
    rename_column :customers, :krus_sync_date, :billing_sync_date
  end

  def self.down
    rename_column :customers, :billing_sync_date, :krus_sync_date
  end
end
