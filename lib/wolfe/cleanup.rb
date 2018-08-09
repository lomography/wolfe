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
        monthly_date = set_monthly_date(config['one_per_month_timespan'])
        keep_one = !one_per_month_timespan_starts_with_zero?(config['one_per_month_timespan'])

        if File.directory?(config['path'])
          clean_monthly( monthly_date, daily_date, config, keep_one )
          clean_yearly( monthly_date, config, keep_one ) if keep_one
        else
          puts "Path '#{config['path']}' is not a directory."
        end
      end

      def set_monthly_date(one_per_month_timespan)
        if Date.today - eval(one_per_month_timespan) == Date.today
          @first_relevant_date
        else
          Date.today - eval(one_per_month_timespan)
        end
      end

      def one_per_month_timespan_starts_with_zero?(timespan)
        timespan.first.to_i == 0 ? true : false
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

        select_file_for_deletion(keep_one, path, filename_day, date, filename_month: filename_month)
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

        select_file_for_deletion(keep_one, path, filename_day, date, filename_year: filename_year)
      end

      def select_file_for_deletion(keep_one, path, filename_day, date, filename_month: nil, filename_year: nil)
        if keep_one
          select_file(full_path(path, filename_month), delete_path: full_path(path, filename_day)) if filename_month
          select_file(full_path(path, filename_year), delete_path: full_path(path, filename_day)) if filename_year
        else
          select_file(delete_path: full_path( path, filename_day))
        end
      end

      def full_path( path, filename )
        File.expand_path(File.join(path, filename))
      end

      def select_file(keep_path=nil, delete_path:)
        Dir.glob(delete_path).each do |f|
          if File.size(Dir.glob(month_path(f)).sort.last) > 0
            keep_path ? delete_but_keep_one(f, keep_path) : delete_without_keeping_one(f)
          end
        end
      end

      def delete_but_keep_one(file, keep_path)
        if Dir.glob(keep_path).count > 1
          delete(file)
        end
      end

      def delete_without_keeping_one(file)
        next_file = file.dup
        date = date_from_file(file)
        next_file[52..61] = date.next.to_s

        if File.size(Dir.glob(next_file).last) > 0
          delete(file)
        end
      end

      def delete(file)
        puts "Delete: #{file}"
        FileUtils.rm(file)
      end

      def month_path(file)
        file_splitted = file.split('-')
        file_splitted[-2] = "*"
        file_splitted[-1] = "*"
        file_splitted.join('-')
      end

      def date_from_file(file)
        file_splitted = file.split('-')
        file_splitted[-4..-2].join('.').to_date
      end
  end
end
