class AddAliasesToStreets < ActiveRecord::Migration
  def self.up
    add_column :streets, :aliases, :string
  end

  def self.down
    remove_column :streets, :aliases
  end
end
