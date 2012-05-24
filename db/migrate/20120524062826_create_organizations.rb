class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.column :title, :string, :null => false
      t.column :is_default, :boolean, :default => false, :null => false
    end
    
    Organization.create(:title => "Default organization", :is_default => true)
    Organization.create(:title => "Second organization")
    
    add_column :incoming_letters, :organization_id, :integer
    add_column :outgoing_letters, :organization_id, :integer
    
    IncomingLetter.update_all(:organization_id => Organization.default.id)
    OutgoingLetter.update_all(:organization_id => Organization.default.id)
    
    add_column :previous_codes, :organization_id, :integer
    
    PreviousCode.update_all(:organization_id => Organization.default.id)    
  end

  def self.down
    drop_table :organizations
    remove_column :incoming_letters, :organization_id
    remove_column :outgoing_letters, :organization_id
    remove_column :previous_codes, :organization_id
  end
end
