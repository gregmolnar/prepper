require 'tty/option'
module Prepper
  class Cli
    include TTY::Option
    usage do
      program 'Prepper'
      command 'run'
      desc 'provision your server'
    end

    argument :config_file do
      desc 'path to config file'
    end

    def run
      if params[:help]
        print help and exit
      else
        Prepper::Runner.run(File.read(params[:config_file]))
      end
    end
  end
end
