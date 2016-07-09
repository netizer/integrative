class User < ApplicationRecord
  integrates :category
  integrates :facebook
  integrates :relation, requires: [:user]
end
