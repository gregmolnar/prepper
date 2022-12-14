require_relative 'lib/prepper/version'

Gem::Specification.new do |spec|
  spec.name          = "prepper"
  spec.version       = Prepper::VERSION
  spec.authors       = ["Greg Molnar"]
  spec.email         = ["molnargerg@gmail.com"]

  spec.summary       = "Simple server provisioning"
  spec.description   = "Simple server provisioning "
  spec.homepage      = "https://github.com/gregmolnar/prepper"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gregmolnar/prepper"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = "prepper"
  spec.require_paths = ["lib"]

  spec.add_dependency 'zeitwerk'
  spec.add_dependency 'sshkit'
  spec.add_dependency 'tty-option'
  spec.add_development_dependency 'byebug'
end
