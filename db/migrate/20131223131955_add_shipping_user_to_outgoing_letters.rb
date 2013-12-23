class AddShippingUserToOutgoingLetters < ActiveRecord::Migration
  def change
    add_column :outgoing_letters, :shipping_user_id, :integer
  end
end
