# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wolfe/version'

Gem::Specification.new do |spec|
  spec.name          = "wolfe"
  spec.version       = Wolfe::VERSION
  spec.authors       = ["Michael Emhofer", "Martin Sereinig"]
  spec.email         = ["dev@lomography.com"]

  spec.summary       = %q{Cleanup (backup) files by date.}
  spec.description   = "Often backup files have year, month, date and hour encoded in their filename. " \
                       "Wolfe uses this information to clean up such files and can be configured to " \
                       "keep daily/monthly backups for a certain timespans. It will always keep one backup per year."
  spec.homepage      = "http://github.com/lomography/wolfe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "timecop"
end
