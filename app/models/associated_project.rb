class AssociatedProject < ActiveRecord::Base
  unloadable
  belongs_to :outgoing_letter
  belongs_to :incoming_letter
end
