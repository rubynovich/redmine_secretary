class AddProjectIdToIncomingIssue < ActiveRecord::Migration
  def change
    #add_column :incoming_issues, :project_id, :integer
    IncomingIssue.where(:project_id => nil).find_each do |incoming_issue|
      incoming_issue.update_attribute(:project_id, incoming_issue.issue.try(:project_id))
    end
  end
end
