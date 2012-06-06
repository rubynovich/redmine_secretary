class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.column :title, :string, :null => false
      t.column :is_default, :boolean, :default => false, :null => false
      t.column :position, :integer
    end
    add_column :incoming_letters, :organization_id, :integer
    add_column :outgoing_letters, :organization_id, :integer
    add_column :previous_codes, :organization_id, :integer    
  end

  def self.down
    drop_table :organizations
    remove_column :incoming_letters, :organization_id
    remove_column :outgoing_letters, :organization_id
    remove_column :previous_codes, :organization_id
  end
end
