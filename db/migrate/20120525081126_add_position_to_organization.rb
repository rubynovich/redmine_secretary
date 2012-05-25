class AddPositionToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :position, :integer, :default => 1
    pos = 1
    Organization.find_each do |org|
      org.update_attribute(:position, pos+=1)
    end    
  end

  def self.down
    remove_column :organizations, :position
  end
end
