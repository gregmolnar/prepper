require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/sshkit_ext.rb")
loader.setup

require 'sshkit_ext'

module Prepper
  class Error < StandardError; end
  # Your code goes here...
end
