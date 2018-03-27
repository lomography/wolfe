require "active_support"
require "active_support/core_ext"
require "fileutils"

module Wolfe
  class Cleanup
    attr_accessor :configuration

    def initialize(configuration)
      @configuration = configuration
      validate_configuration
      @first_relevant_date = Date.today - 5.years
    end

    def start
      configuration.each do |name, config|
        puts "-----------------------------------------------------"
        puts "Cleaning up backups: #{name}"
        puts "-----------------------------------------------------"

        cleanup( config )
      end
    end

    private

      #
      # validation
      #

      def validate_configuration
        raise ArgumentError.new("Configuration must be hash.") unless configuration.is_a? Hash
        configuration.each do |name, config|
          raise ArgumentError.new("Configuration keys for #{name} missing.") unless configuration_keys.all? { |k| config.key?(k) }
          raise ArgumentError.new("Invalid timespan argument for #{name}")   unless config['one_per_day_timespan'] =~ timespan_regex
          raise ArgumentError.new("Invalid timespan argument for #{name}")   unless config['one_per_month_timespan'] =~ timespan_regex
          raise ArgumentError.new("Path for #{name} does not exist.")        unless Dir.exist?(config['path'])
        end
      end

      def configuration_keys
        ['path', 'filename', 'one_per_day_timespan', 'one_per_month_timespan']
      end

      def timespan_regex
        /^\d+\.(days?|weeks?|months?|years?)$/
      end

      #
      # cleanup
      #

      def cleanup( config )
        daily_date = Date.today - eval( config['one_per_day_timespan'] )
        monthly_date = Date.today - eval( config['one_per_month_timespan'] )

        if File.directory?(config['path'])
          keep_one = true

          if monthly_date == Date.today
            keep_one = false
            monthly_date = @first_relevant_date
          end

          clean_monthly( monthly_date, daily_date, config, keep_one )
          clean_yearly( monthly_date, config, keep_one )
        else
          puts "Path '#{config['path']}' is not a directory."
        end
      end

      def clean_monthly( monthly_date, daily_date, config, keep_one )
        monthly_date.upto( daily_date ) do |date|
          delete_monthly( config['path'], config['filename'], date, keep_one )
        end
      end

      def clean_yearly( monthly_date, config, keep_one )
        @first_relevant_date.upto( monthly_date ) do |date|
          delete_yearly( config['path'], config['filename'], date, keep_one )
        end
      end

      def delete_monthly( path, filename, date, keep_one )
        filename_month = filename % { year: date.strftime('%Y'),
                                     month: date.strftime('%m'),
                                       day: '*',
                                      hour: '*' }
        filename_day = filename % { year: date.strftime('%Y'),
                                   month: date.strftime('%m'),
                                     day: date.strftime('%d'),
                                    hour: '*' }

        to_keep_or_not_to_keep?(keep_one, path, filename_day, filename_month: filename_month)
      end

      def delete_yearly( path, filename, date, keep_one )
        filename_year = filename % { year: date.strftime('%Y'),
                                    month: '*',
                                      day: '*',
                                     hour: '*' }
        filename_day = filename % { year: date.strftime('%Y'),
                                   month: date.strftime('%m'),
                                     day: date.strftime('%d'),
                                    hour: '*' }

        to_keep_or_not_to_keep?(keep_one, path, filename_day, filename_year: filename_year)
      end

      def to_keep_or_not_to_keep?(keep_one, path, filename_day, filename_month: nil, filename_year: nil)
        if keep_one
          select_file_for_deletion( full_path( path, filename_month ), delete_path: full_path( path, filename_day ) ) if filename_month
          select_file_for_deletion( full_path( path, filename_year ), delete_path: full_path( path, filename_day ) ) if filename_year
        else
          select_file_for_deletion( delete_path: full_path( path, filename_day ) )
        end
      end

      def full_path( path, filename )
        File.expand_path(File.join(path, filename))
      end

      def select_file_for_deletion(keep_path=nil, delete_path:)
        Dir.glob(delete_path).each do |f|
          keep_path ? delete_but_keep_one(f, keep_path) : delete_without_keeping_one(f, delete_path)
        end
      end

      def delete_but_keep_one(file, keep_path)
        if Dir.glob(keep_path).count > 1 && File.size(Dir.glob(keep_path).sort.last) > 0
          delete_file(file)
        end
      end

      def delete_without_keeping_one(file, delete_path)
        if File.size(Dir.glob(delete_path).last) > 0
          delete_file(file)
        end
      end

      def delete_file(file)
        puts "Delete: #{file}"
        FileUtils.rm(file)
      end
  end
end
