module Integrative
  class Integration
    attr_accessor :name
    attr_accessor :integrator_class
    attr_accessor :integrated_class
    attr_accessor :init_options
    attr_accessor :call_options
    attr_accessor :integrator_key
    attr_accessor :integrated_key

    def initialize(name, integrator_class, options)
      @name = name
      @integrator_class = integrator_class
      @integrated_class = name.to_s.camelize.constantize
      @init_options = options
      designated_key = integrator_class.column_names.find { |col| col == "#{name}_id" }
      if designated_key
        @integrator_key = designated_key.to_sym
        @integrated_key = :id
      else
        @integrator_key = :id
        @integrated_key = "#{integrator_class.name.underscore}_id"
      end
    end

    def invalidate
      if call_options.blank? && init_options[:requires].present?
        throw "You used 'integrate' for #{name} without options," +
          " but the following options are required: #{init_options[:requires]}"
      end

      if call_options.present? && init_options[:requires].blank?
        throw "You used 'integrate' for #{name} with unexpected options," +
          " you should define integration like this:" +
          " 'integrates :#{name}, requires: [:#{call_options.keys.join(", :")}]'"
      end

      if call_options.present? && init_options[:requires].present?
        too_many_options = call_options.keys - init_options[:requires]
        too_little_options = init_options[:requires] - call_options.keys

        if too_many_options.present?
          throw "You used 'integrate' for #{name}" +
            " with too many options: #{too_many_options}"
        end

        if too_little_options.present?
          throw "You used 'integrate' for #{name}" +
            " with too little options: #{too_little_options}"
        end
      end
    end

    def setter
      "#{name}="
    end
  end
end
