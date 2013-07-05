class CreateOutgoingProjects < ActiveRecord::Migration
  def change
    create_table :outgoing_projects do |t|
      t.integer :outgoing_letter_id
      t.integer :project_id
      t.timestamps
    end
  end
end
