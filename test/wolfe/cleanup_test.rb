require 'test_helper'

module Wolfe

  class CleanupTest < Minitest::Test

    #
    # validations
    #

    def test_configuration_must_be_a_hash
      assert_raises ArgumentError do
        Cleanup.new("wat")
      end
    end

    def test_configuration_must_include_valid_paths
      assert_raises ArgumentError do
        Cleanup.new(configuration("/not/really/a/path/", "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "1.days"))
      end
    end

    def test_configuration_must_include_all_keys
      assert_raises ArgumentError do
        Cleanup.new('test_backup' => { 'path' => test_directory, 'one_per_day_timespan' => "30.days", 'one_per_month_timespan' => "1.year" })
      end
    end

    def test_configuration_must_have_valid_timespans
      assert_raises ArgumentError do
        Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "5.days", "Dir.exist?('/tmp')" ) )
      end
    end

    #
    # actual cleanup
    #

    def test_start_should_correctly_delete_daily_backups
      create_test_files_downto 15.days.ago
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "1.year"))
      cleanup.start

      if ( Date.today - 15.days ).month != Date.today.month
        assert_equal 6, Dir.entries(test_directory).count
        assert File.exist?("#{test_directory}/#{backup_filename( (Date.today - 15.days).end_of_month )}")
      else
        assert_equal 5, Dir.entries(test_directory).count
      end

      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
    end

    def test_start_should_correctly_delete_monthly_backups
      create_test_files_downto 6.months.ago
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "3.months"))
      cleanup.start

      assert_equal 5, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(1.month.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.months.ago.end_of_month.to_date)}")
    end

    #
    # setup/teardown
    #

    def setup
      Dir.mkdir(test_directory) unless Dir.exist?(test_directory)
    end

    def teardown
      FileUtils.remove_dir(test_directory, true) if Dir.exist?(test_directory)
    end

    private

      def create_test_files_downto datetime
        Date.today.downto(datetime.to_date) do |date|
          FileUtils.touch "#{test_directory}/#{backup_filename(date)}"
        end
      end

      def test_directory
        File.join( File.expand_path(File.dirname(__FILE__)), '..', 'tmp' )
      end

      def backup_filename date
        "test_backup-%04d-%02d-%02d-10" % [date.year, date.month, date.day]
      end

      def configuration path, filename, day_timespan, month_timespan
        {
          'test_backup' =>
            {
              'path' => path,
              'filename' => filename,
              'one_per_day_timespan' => day_timespan,
              'one_per_month_timespan' => month_timespan,
            }
        }
      end
  end
end
