#  Integrative lets you add objects to ActiveRecord relation or to an array
#
#   class User < ApplicationRecord
#     integrates :relation, require: [:with]
#   end
#
#   class Relation
#     include Integrative::Integrated
#
#     attr_accessor :user_id
#     attr_accessor :kind
#
#     ...
#   end
#
# Now let's say you would like to have the list of all users with their relations.
# Try this:
#
#   users = User.limit(1000).integrate(:relation, with: current_user).to_a
#
# and the integration of relations will happen for the whole collection and not
# just for individual users.
require 'integrative/utils'

module Integrative
  extend Utils

  autoload :Integrator,  'integrative/integrator'
  autoload :Integrated,  'integrative/integrated'
  autoload :Integration, 'integrative/integration'
  autoload :Errors,      'integrative/errors'
  autoload :Extensions,  'integrative/extensions'
end


