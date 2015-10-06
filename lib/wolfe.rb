require "yaml"

require "wolfe/cleanup"
require "wolfe/version"

module Wolfe
  def self.run_cleanup file_path
    config = YAML::load_file( file_path )
    cleanup = Cleanup.new(config)
    cleanup.start
  end
end
