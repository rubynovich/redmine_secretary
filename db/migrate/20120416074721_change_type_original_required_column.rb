class ChangeTypeOriginalRequiredColumn < ActiveRecord::Migration
  def self.up
    remove_column :incoming_letters, :original_required
    add_column :incoming_letters, :original_required, :string
  end

  def self.down
    remove_column :incoming_letters, :original_required
    add_column :incoming_letters, :original_required, :boolean  
  end
end
