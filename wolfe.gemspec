# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "lib/wolfe/version"

Gem::Specification.new do |spec|
  spec.name          = "wolfe"
  spec.version       = Wolfe::VERSION
  spec.authors       = ["Michael Emhofer", "Martin Sereinig"]
  spec.email         = ["dev@lomography.com"]

  spec.required_ruby_version = ">= 3.3"

  spec.homepage = "https://github.com/lomography/wolfe"
  spec.license = "MIT"

  spec.summary = %q{Cleanup (backup) files by date.}
  spec.description = "Often backup files have year, month, date and hour encoded in their filename. " \
                      "Wolfe uses this information to clean up such files and can be configured to " \
                      "keep daily/monthly backups for a certain timespans. It will always keep one backup per year."

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "exe/*", "README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir = "exe"
  spec.executables = ["wolfe"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 8.0"
  spec.add_dependency "thor", ">= 1.3"
end
