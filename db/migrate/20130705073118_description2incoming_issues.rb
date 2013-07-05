class Description2incomingIssues < ActiveRecord::Migration
  def up
    IncomingLetter.find_each do |incoming_letter|
      IncomingIssue.transaction do
        incoming_letter.description.scan(/\#(\d+)/).flatten.map(&:to_i).each do |issue_id|
          p IncomingIssue.create(incoming_letter_id: incoming_letter.id, issue_id: issue_id)
        end
      end
    end
  end

  def down
  end
end
