module Integrative
  class Integration
    attr_accessor :name
    attr_accessor :integrator_class
    attr_accessor :integrated_class

    def initialize(name, integrator_class, options)
      @name = name
      @integrator_class = integrator_class
      @integrated_class = name.to_s.camelize.constantize
    end

    def setter
      "#{name}="
    end
  end
end
