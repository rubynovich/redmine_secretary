class SecretaryProject < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :user
  belongs_to :organization

  validates_presence_of :user_id, :project_id, :organization_id
  validates_associated :user, :project, :organization
  validates_uniqueness_of :user_id, :scope => [:project_id, :organization_id]
  validates_uniqueness_of :project_id, :scope => [:user_id, :organization_id]  
end
