class AddRecipientUserToIncommingLetters < ActiveRecord::Migration
  def change
    add_column :incoming_letters, :recipient_user_id, :integer
  end
end
