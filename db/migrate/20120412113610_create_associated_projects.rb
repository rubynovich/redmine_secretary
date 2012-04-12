class CreateAssociatedProjects < ActiveRecord::Migration
  def self.up
    create_table :associated_projects do |t|
      t.integer :project_id
      t.integer :incoming_letter_id
      t.integer :outgoing_letter_id
    end
  end

  def self.down
    drop_table :associated_projects
  end
end
