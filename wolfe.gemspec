# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wolfe/version'

Gem::Specification.new do |spec|
  spec.name          = "wolfe"
  spec.version       = Wolfe::VERSION
  spec.authors       = ["Michael Emhofer", "Martin Sereinig"]
  spec.email         = ["dev@lomography.com"]

  spec.summary       = %q{Cleans up (backup) files by date.}
  spec.homepage      = "http://github.com/lomography"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "byebug"
end
