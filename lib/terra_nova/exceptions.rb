module TerraNova
  module Exceptions
    class InvalidDomain < StandardError
      def initialize(target_domain)
        super("Could not find #{target_domain} as a registered zone")
      end
    end
  end
end
