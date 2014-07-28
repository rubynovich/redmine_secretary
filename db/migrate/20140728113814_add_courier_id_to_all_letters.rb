class AddCourierIdToAllLetters < ActiveRecord::Migration
  def self.up
    add_column :incoming_letters, :courier_id, :integer
  end

  def self.down
    remove_column :incoming_letters, :courier_id
  end

end
