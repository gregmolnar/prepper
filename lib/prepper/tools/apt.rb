module Prepper
  module Tools
    module Apt
      def self.included(base)
        base.class_eval do
          def apt
            # coming soon
          end
        end
      end
    end
  end
end
