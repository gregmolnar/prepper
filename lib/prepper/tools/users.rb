module Prepper
  module Tools
    module Users
      def self.included(base)
        base.class_eval do
          def add_user(username, opts = {})
            opts[:flags] << ' --gecos ,,,'
            @commands << Command.new("adduser #{username} #{opts[:flags]}", sudo: true, verifier: has_user?(username))
          end

          def has_user?(username, opts = {})
            if opts[:in_group]
              command = "id -nG #{username} | xargs -n1 echo | grep #{opts[:in_group]}"
            else
              command = "id #{username}"
            end
            Command.new(command, sudo: true)
          end
        end
      end
    end
  end
end
