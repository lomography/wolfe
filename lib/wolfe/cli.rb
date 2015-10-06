require 'thor'

module Wolfe

  class CLI < Thor
    desc "cleanup path/to/file.yml", "Will clean up files according to the rules specified in given file."
    def cleanup file
      Wolfe.run_cleanup file
    end
  end

end
