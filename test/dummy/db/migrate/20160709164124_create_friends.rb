class CreateFriends < ActiveRecord::Migration[5.0]
  def change
    create_table :friends do |t|
      t.integer :user_id
      t.integer :other_user_id

      t.timestamps
    end
  end
end
