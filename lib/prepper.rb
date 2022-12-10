require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Prepper
  class Error < StandardError; end
  # Your code goes here...
  include Tools::Apt
end
