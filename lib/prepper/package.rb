module Prepper
  class Package
    include SSHKit::DSL
    include Tools::Users
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
      # require 'byebug'; debugger
      @verifications.all? do |verification|
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
        execute_command(command)
      end
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
              send(method, command.to_s).inspect
            end
          end
        end
      end
    end
  end
end
