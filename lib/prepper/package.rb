module Prepper
  class Package
    include SSHKit::DSL
    include Tools::Apt
    include Tools::Users
    include Tools::File
    include Tools::Text
    include Tools::Rbenv

    attr_accessor :name, :runner, :commands, :verifications

    def initialize(name, opts = {}, &block)
      @name = name
      @opts = opts
      @runner = opts[:runner]
      @verifications = []
      @commands = []
      instance_eval &block if block_given?
    end

    def should_run?
      return true if @verifications.empty?
      return @verifications.all? do |verification|
        !test_command(verification.call)
      end
    end

    def verify(&block)
      @verifications << block
    end

    def process
      unless should_run?
        SSHKit.config.output.write(SSHKit::LogMessage.new(1, "Skipping package #{name}"))
        return
      end
      @commands.each do |command|
        if command.verifier
          if !test_command(command.verifier)
            execute_command(command)
          else
            SSHKit.config.output.write(SSHKit::LogMessage.new(1, "Skipping command #{command.to_s}"))
          end
        else
          execute_command(command)
        end
      end
    end

    def add_command(command, opts = {})
      opts[:user] ||= "root"
      opts[:within] ||= "/"
      @commands << Command.new(command, opts)
    end

    def execute_command(command)
      run_command(:execute, command)
    end

    def test_command(command)
      run_command(:test, command)
    end

    def run_command(method, command)
      on [runner.server_hash], in: :sequence do |host|
        within command.within do
          as command.user  do
            with command.env do
              if respond_to? command.to_s.to_sym
                send command.to_s.to_sym, *command.opts[:params]
              else
                if method == :execute
                  execute command.to_s
                else

                send(method, command.to_s)
                end
              end
            end
          end
        end
      end
    end
  end
end
