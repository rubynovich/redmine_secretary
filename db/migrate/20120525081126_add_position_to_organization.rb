class AddPositionToOrganization < ActiveRecord::Migration
  def self.up
    Organization.create(:title => "Default organization", :is_default => true, :position => 1)
    Organization.create(:title => "Second organization", :position => 2)
    IncomingLetter.update_all(:organization_id => Organization.default.id)
    OutgoingLetter.update_all(:organization_id => Organization.default.id)    
    PreviousCode.update_all(:organization_id => Organization.default.id)    
  end

  def self.down
    remove_column :organizations, :position
  end
end
