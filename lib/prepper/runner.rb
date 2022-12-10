require 'sshkit'
require 'sshkit/dsl'
module Prepper
  class Runner
    include SSHKit::DSL

    attr_accessor :host

    def self.run(config)
      runner = new
      runner.instance_eval config
      runner.run
    end

    def initialize
      @package_registry = PackageRegistry.new
      @commands = []
      @user = "root"
      @port = 22
    end

    def run
      puts "running on #{@host}"
      @commands.each do |command|
        on [{hostname: @host, user: @user, port: @port, ssh_options: @ssh_options}], in: :sequence do |host|
          puts "Now executing on #{host}"
          within command.within do
            as command.user  do
              with command.env do
                execute command.to_s
              end
            end
          end
        end
      end
    end

    def host(host)
      @host = host
    end

    def user(user)
      @user = user
    end

    def port(port)
      @port = port
    end

    def ssh_options(ssh_options)
      @ssh_options = ssh_options
    end


    def add_command(command, opts = {})
      opts[:user] ||= "root"
      opts[:within] ||= "/"
      @commands << Command.new(command, opts)
    end
  end
end
