class IncomingIssue < ActiveRecord::Base
  unloadable

  belongs_to :issue
  has_one :project, :through => :issue
  belongs_to :incoming_letter

  validates_presence_of :issue_id, :incoming_letter_id
  validates_uniqueness_of :issue_id, :scope => :incoming_letter_id

  before_save :put_project_id

  def put_project_id
    self.project_id = self.issue.try(:project_id)
  end
end
