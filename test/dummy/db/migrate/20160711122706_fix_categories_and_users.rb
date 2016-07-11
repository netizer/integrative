class FixCategoriesAndUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :category_id, :integer
    remove_column :categories, :user_id, :integer
  end
end
