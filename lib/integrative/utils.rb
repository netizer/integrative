module Integrative
  module Utils
    def integrate_into(records, integration_name, options = {})
      if records.length > 0
        integration = Integration.new(integration_name, records.first.class, options)
        integration.integrated_class.integrative_find_and_assign(records, integration)
      end
    end
  end
end
