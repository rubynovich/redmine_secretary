class CreateOutgoingLetters < ActiveRecord::Migration
  def self.up
    create_table :outgoing_letters do |t|
      t.string    :code
      t.string    :incoming_code
      t.text      :description
      t.string    :signer      
      t.string    :recipient
      t.datetime  :shipping_on
      t.string    :shipping_type      
      t.string    :shipping_place
      t.datetime  :served_on
      t.integer   :author_id
      t.datetime  :created_on
    end
  end

  def self.down
    drop_table :outgoing_letters
  end
end
