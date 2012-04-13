class RenameFields < ActiveRecord::Migration
  def self.up
    rename_column :incoming_letters, :user_id, :executor_id
    rename_column :incoming_letters, :code, :incoming_code
    rename_column :incoming_letters, :shipping_place, :shipping_from
    rename_column :outgoing_letters, :code, :outgoing_code
    rename_column :outgoing_letters, :shipping_place, :shipping_to
  end

  def self.down
    rename_column :incoming_letters, :executor_id, :user_id
    rename_column :incoming_letters, :incoming_code, :code
    rename_column :incoming_letters, :shipping_from, :shipping_place
    rename_column :outgoing_letters, :outgoing_code, :code
    rename_column :outgoing_letters, :shipping_to, :shipping_place
  end
end
