module Prepper
  class Command
    attr_reader :command, :user, :within, :env, :sudo

    def initialize(command, opts)
      @command = command
      @user = opts[:user]
      @within = opts[:within]
      @env = opts[:env] || {}
      @sudo = opts[:sudo] || false
    end

    def to_s
      if @sudo
        @command.prepend("sudo ")
      else
        @command
      end
    end
  end
end
