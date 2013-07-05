class OutgoingProject < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :outgoing_letter

  validates_presence_of :project_id, :outgoing_letter_id
  validates_uniqueness_of :project_id, :scope => :outgoing_letter_id
end
