class AddPositionToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :position, :integer, :default => 1
  end

  def self.down
    remove_column :organizations, :position
  end
end
