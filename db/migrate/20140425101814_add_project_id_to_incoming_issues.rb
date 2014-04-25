class AddProjectIdToIncomingIssues < ActiveRecord::Migration
  def change
    add_column :incoming_issues, :project_id, :integer
  end
end
