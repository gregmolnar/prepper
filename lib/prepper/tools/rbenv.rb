module Prepper
  module Tools
    # Helper methods for rbenv
    module Rbenv
      # install rbenv for a given user
      # @param user [String] name of the user to install rbenv for
      def install_rbenv(user)
        apt_install %w{libssl-dev zlib1g zlib1g-dev libreadline-dev}
        @commands << Command.new("sudo -u #{user} -i git clone https://github.com/sstephenson/rbenv.git /home/#{user}/.rbenv", verifier: has_directory?("/home/#{user}/.rbenv"))
        @commands << Command.new("sudo -u #{user} -i git clone https://github.com/sstephenson/ruby-build.git /home/#{user}/.rbenv/plugins/ruby-build", verifier: has_directory?("/home/#{user}/.rbenv/plugins/ruby-build"))

        append_text 'export PATH="$HOME/.rbenv/bin:$PATH"', "/home/#{user}/.profile"
        append_text 'eval "$(rbenv init -)"', "/home/#{user}/.profile"
        chown "/home/#{user}/.profile", 'deploy:deploy'
      end

      # install a given ruby version for a given user
      # @param user [String] name of the user
      # @param version [String] ruby version
      def install_ruby(user, version)
        @commands << Command.new("sudo -u #{user} -i RUBY_CONFIGURE_OPTS='#{opts}' rbenv install #{version}", verifier: has_directory?("/home/#{user}/.rbenv/versions/#{version}"))

        @commands << Command.new("sudo -u #{user} -i rbenv rehash")
        @commands << Command.new("sudo -u #{user} -i rbenv global #{version}")
        @commands << Command.new("sudo -u #{user} -i rbenv rehash")
      end
    end
  end
end
