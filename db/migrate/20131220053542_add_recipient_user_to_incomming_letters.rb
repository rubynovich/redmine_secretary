class AddRecipientUserToIncommingLetters < ActiveRecord::Migration
  def change
    add_column :incomming_letters, :recipient_user_id, :integer
  end
end
