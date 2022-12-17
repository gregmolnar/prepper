module Prepper
  module Tools
    # user management related helpers
    module Users
      # add a user to the host
      # @param username [String] name of the user
      # @param [Hash] opts options has
      # @option opts [String] :flags flags to pass to adduser
      def add_user(username, opts = {})
        opts[:flags] << ' --gecos ,,,'
        @commands << Command.new("adduser #{username} #{opts[:flags]}", sudo: true, verifier: has_user?(username))
      end

      # returns a verifier command to check if a user exists
      # @param username [String] name of the user
      # @param [Hash] opts options hash
      # @option opts [String] :in_group check if the user is in the given group
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
