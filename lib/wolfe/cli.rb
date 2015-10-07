require 'thor'

module Wolfe
  class CLI < Thor
    desc "cleanup path/to/rule/file.yml", "Clean up files according to rules specified in given yaml file."
    def cleanup file
      begin
        Wolfe.run_cleanup file
      rescue ArgumentError => e
        puts "Error: #{e}"
      end
    end
  end
end
