require 'factory_girl'
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end
FactoryGirl.find_definitions
