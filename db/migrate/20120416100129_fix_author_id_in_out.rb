class FixAuthorIdInOut < ActiveRecord::Migration
  def self.up
    unless column_exists? :outgoing_letters, :author_id, :integer
      add_column :outgoing_letters, :author_id, :integer
    end
  end

  def self.down
    remove_column :outgoing_letters, :author_id
  end
end
