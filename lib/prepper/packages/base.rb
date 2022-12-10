module Prepper
  module Packages
    class Base
      include SSHKit::DSL
      attr_accessor :server_hash, :commands

      def initialize(name, opts = {}, &block)
        @name = name
        @opts = opts
        @verifications = []
        @commands = []
        instance_eval &block if block_given?
      end

      def already_run?
        return false if @verifications.empty?
        @verifications.all?(true)
      end

      def process
        return if already_run?
        @commands.each do |command|
          on [server_hash], in: :sequence do |host|
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
    end
  end
end
