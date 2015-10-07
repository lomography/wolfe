require "yaml"

require "wolfe/cleanup"
require "wolfe/cli"
require "wolfe/version"

module Wolfe
  def self.run_cleanup file_path
    raise ArgumentError.new("Cleanup configuration file does not exist.") unless File.exist? file_path

    config = YAML::load_file( file_path )
    cleanup = Cleanup.new(config)
    cleanup.start
  end
end
