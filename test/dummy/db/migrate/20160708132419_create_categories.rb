class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.references :user

      t.timestamps null: false
    end
  end
end
