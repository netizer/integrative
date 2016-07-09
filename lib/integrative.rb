#  Integrative lets you add objects to ActiveRecord relation or to an array
#
#   class User < ApplicationRecord
#     integrates :user_flags
#   end
#
#   class UserFlag < SomeRedisObject
#     attr_accessor :user_id
#     attr_accessor :flags_list
#
#     def extract_ids(objects)
#       objects.map { |obj| "redis_user_flag_#{obj.id}" }
#     end
#
#     def self.fetch(ids)
#       @redis.mget(*ids)
#     end
#   end
#
# Now let's say you would like to see the list of all users with their flags. Try this:
#
#   users = User.limit(1000).integrate(:user_flags).to_a

module Integrative
  autoload :Integrator, 'integrative/integrator'
  autoload :Integrated, 'integrative/integrated'
  autoload :Integration, 'integrative/integration'
end


