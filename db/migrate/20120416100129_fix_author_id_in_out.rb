class FixAuthorIdInOut < ActiveRecord::Migration
  def self.up
    add_column :outgoing_letters, :author_id, :integer
  end

  def self.down
    remove_column :outgoing_letters, :author_id
  end
end
