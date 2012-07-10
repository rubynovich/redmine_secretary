  class AddAnwerForLetters < ActiveRecord::Migration
  def self.up
    add_column :incoming_letters, :answer_for, :string
    add_column :outgoing_letters, :answer_for, :string
  end

  def self.down
    remove_column :incoming_letters, :answer_for
    remove_column :outgoing_letters, :answer_for
  end
end
