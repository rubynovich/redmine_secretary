class CreateSecretaryProjects < ActiveRecord::Migration
  def self.up
    create_table :secretary_projects do |t|
      t.column :organization_id, :integer
      t.column :project_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :secretary_projects
  end
end
