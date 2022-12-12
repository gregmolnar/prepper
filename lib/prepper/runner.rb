require 'sshkit'
require 'sshkit/dsl'
module Prepper
  class Runner

    attr_accessor :host, :packages, :commands, :user, :port

    def self.run(config)
      runner = new
      runner.instance_eval config
      runner.run
    end

    def initialize
      @packages = []
      @commands = []
      @user = "root"
      @port = 22
    end

    def run
      puts "running on #{host}"
      @packages.each(&:process)
    end

    def server_host(host)
      @host = host
    end

    def server_user(user)
      @user = user
    end

    def server_port(port)
      @port = port
    end

    def ssh_options(ssh_options)
      @ssh_options = ssh_options
    end

    def server_hash
      {hostname: host, user: user, port: port, ssh_options: @ssh_options}
    end

    def add_command(command, opts = {})
      package = Package.new("base", opts)
      package.runner = self
      opts[:user] ||= "root"
      opts[:within] ||= "/"
      package.commands << Command.new(command, opts)
      @packages << package
    end

    def package(name, opts = {}, &block)
      @packages << Package.new(name, opts.merge(runner: self), &block)
    end
  end
end
