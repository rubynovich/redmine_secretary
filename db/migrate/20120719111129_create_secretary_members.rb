class CreateSecretaryMembers < ActiveRecord::Migration
  def self.up
    create_table :secretary_members do |t|
      t.column :user_id, :integer
      t.column :organization_id, :integer
      t.column :incoming_new, :boolean
      t.column :incoming_edit, :boolean
      t.column :incoming_delete, :boolean
      t.column :outgoing_new, :boolean
      t.column :outgoing_edit, :boolean
      t.column :outgoing_delete, :boolean
    end
  end

  def self.down
    drop_table :secretary_members
  end
end
