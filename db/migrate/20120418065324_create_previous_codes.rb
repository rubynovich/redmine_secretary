class CreatePreviousCodes < ActiveRecord::Migration
  def self.up
    create_table :previous_codes do |t|
      t.column :name, :string
      t.column :value, :string
      t.column :year, :string
      t.column :updated_on, :datetime
    end
  end

  def self.down
    drop_table :previous_codes
  end
end
