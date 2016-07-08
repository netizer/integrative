class ApplicationRecord < ActiveRecord::Base
  include Integrative::Integrator

  self.abstract_class = true
end
