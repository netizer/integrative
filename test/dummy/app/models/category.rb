class Category < ApplicationRecord
  has_many :users

  integrates :recently_added_user
  # this relation is here only for testing an exception
  integrates :flag, requires: [:a, :b]
end
