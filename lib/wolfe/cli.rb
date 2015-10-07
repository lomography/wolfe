require 'thor'

module Wolfe
  class CLI < Thor
    desc "cleanup path/to/file.yml", "Will clean up files according to the rules specified in given file."
    def cleanup file
      begin
        Wolfe.run_cleanup file
      rescue ArgumentError => e
        puts "Error: #{e}"
      end
    end
  end
end
