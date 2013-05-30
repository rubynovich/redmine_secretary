class AddSubjectToOutgoingLetter < ActiveRecord::Migration
  def change
    add_column :outgoing_letters, :subject, :string
  end
end
