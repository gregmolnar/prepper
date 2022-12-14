module Prepper
  module Tools
    module Apt
      def self.included(base)
        base.class_eval do

          # Updates apt repositories
          def apt_update
            @commands << Command.new("apt update", sudo: true)
          end

          # Installs packages
          # @param packages [Array] array of package names
          def apt_install(packages)
            packages.each do |package|
              @commands << Command.new("apt install --force-yes -qyu #{package}", sudo: true, verify: has_apt_package?(package))
            end
          end

          def has_apt_package?(package)
            Command.new("dpkg --status #{package} | grep 'ok installed'", sudo: true)
          end
        end
      end
    end
  end
end
