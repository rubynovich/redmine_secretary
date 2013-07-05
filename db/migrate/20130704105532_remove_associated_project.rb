class RemoveAssociatedProject < ActiveRecord::Migration
  def up
    drop_table :associated_projects
  end

  def down
  end
end
