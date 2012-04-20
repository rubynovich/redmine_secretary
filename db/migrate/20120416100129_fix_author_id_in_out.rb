class FixAuthorIdInOut < ActiveRecord::Migration
  def self.up
    unless OutgoingLetter.column_names.include?("author_id")
      add_column :outgoing_letters, :author_id, :integer
    end
  end

  def self.down
    remove_column :outgoing_letters, :author_id
  end
end
