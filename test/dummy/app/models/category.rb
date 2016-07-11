class Category < ApplicationRecord
  has_many :users

  integrates :recently_added_user
end
