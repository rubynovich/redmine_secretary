class AddProjectIdToIncomingIssue < ActiveRecord::Migration
  def change
    add_column :incoming_issues, :project_id, :integer
    IncomingIssue.where(:project_id => nil).find_each do |incoming_issue|
      p incoming_issue.save
    end
  end
end
