module Prepper
  module Tools
    # Helper methods to interact with Apt
    module Apt
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

      # Verifier command to checks if an apt package is installed
      # @param package [String] name of the package
      def has_apt_package?(package)
        Command.new("dpkg --status #{package} | grep 'ok installed'", sudo: true)
      end
    end
  end
end
