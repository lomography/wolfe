require "active_support"
require "active_support/core_ext"
require "fileutils"

module Wolfe
  class Cleanup
    attr_accessor :configuration

    def initialize(configuration)
      @configuration = configuration
      validate_configuration
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
          raise ArgumentError.new("Invalid timespan argument for #{name}")unless config[:one_per_day_timespan] =~ timespan_regex
          raise ArgumentError.new("Invalid timespan argument for #{name}") unless config[:one_per_month_timespan] =~ timespan_regex
          raise ArgumentError.new("Path for #{name} does not exist.") unless Dir.exist?(config[:path])
        end
      end

      def configuration_keys
        [:path, :filename, :one_per_day_timespan, :one_per_month_timespan]
      end

      def timespan_regex
        /^\d+\.(days?|weeks?|months?|years?)$/
      end

      #
      # cleanup
      #

      def cleanup( config )
        daily_date = Date.today - eval( config[:one_per_day_timespan] )
        monthly_date = Date.today - eval( config[:one_per_month_timespan] )
        first_relevant_date = Date.today - 5.years

        puts "==> #{config[:path]}"

        if File.directory?(config[:path])
          clean_monthly( monthly_date, daily_date, config )
          clean_yearly( first_relevant_date, monthly_date, config )
        else
          puts "Path '#{config[:path]}' is not a directory."
        end
      end

      def clean_monthly( monthly_date, daily_date, config )
        daily_date.downto( monthly_date ) do |date|
          delete_but_keep_one_per_month( config[:path], config[:filename], date )
        end
      end

      def clean_yearly( first_relevant_date, monthly_date, config )
        monthly_date.downto( first_relevant_date ) do |date|
          delete_but_keep_one_per_year( config[:path], config[:filename], date )
        end
      end

      def delete_but_keep_one_per_month( path, filename, date )
        filename_month = filename % { year: date.strftime('%Y'),
                                     month: date.strftime('%m'),
                                       day: '*',
                                      hour: '*' }
        filename_day = filename % { year: date.strftime('%Y'),
                                   month: date.strftime('%m'),
                                     day: date.strftime('%d'),
                                    hour: '*' }
        delete_but_keep_one( full_path( path, filename_month ), full_path( path, filename_day ) )
      end

      def delete_but_keep_one_per_year( path, filename, date )
        filename_year = filename % { year: date.strftime('%Y'),
                                    month: '*',
                                      day: '*',
                                     hour: '*' }
        filename_day = filename % { year: date.strftime('%Y'),
                                   month: date.strftime('%m'),
                                     day: date.strftime('%d'),
                                    hour: '*' }
        delete_but_keep_one( full_path( path, filename_year ), full_path( path, filename_day ) )
      end

      def full_path( path, filename )
        File.expand_path(File.join(path, filename))
      end

      def delete_but_keep_one( keep_path, delete_path )
        Dir.glob(delete_path).each do |f|
          if Dir.glob(keep_path).count > 1
            puts "Delete: #{f}"
            FileUtils.rm(f)
          end
        end
      end
  end
end
