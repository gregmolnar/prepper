module Prepper
  class Command
    attr_reader :command, :user, :within, :env, :sudo, :opts, :verifier

    def initialize(command, opts = {})
      @command = command
      @opts = opts
      @user = opts[:user] || "root"
      @within = opts[:within] || "/"
      @env = opts[:env] || {}
      @sudo = opts[:sudo] || false
      @verifier = opts[:verifier]
    end

    def to_s
      if @sudo
        @command.dup.prepend("sudo ")
      else
        @command
      end
    end
  end
end
