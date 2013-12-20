class AddSignerUserToOutgoingLetters < ActiveRecord::Migration
  def change
    add_column :outgoing_letters, :signer_user_id, :integer
  end
end
