class AddSubjectToIncommingLetter < ActiveRecord::Migration
  def change
    add_column :incoming_letters, :subject, :string
  end
end
