class CreateIncomingIssues < ActiveRecord::Migration
  def change
    create_table :incoming_issues do |t|
      t.integer :incoming_letter_id
      t.integer :issue_id
      t.timestamps
    end
  end
end
