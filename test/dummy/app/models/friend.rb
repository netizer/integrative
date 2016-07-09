# It's a simple implementation of user relations
# The idea is that when user A become a friend of user B
# then we create 2 records in friends table:
# Friend.create(user: A, other_user: B)
# and Friend.create(user: B, other_user: A)
class Friend < ApplicationRecord
  belongs_to :user
  belongs_to :other_user, class_name: "User"
end
