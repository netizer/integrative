class User < ApplicationRecord
  belongs_to :category

  integrates :facebook
  integrates :relation, requires: [:user]
end
