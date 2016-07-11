class User < ApplicationRecord
  belongs_to :category

  integrates :facebook
  integrates :relation, requires: [:with]
  integrates :flags, array: true
end
