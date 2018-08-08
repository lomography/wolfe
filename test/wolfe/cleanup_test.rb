require_relative "../test_helper"

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
      create_not_empty_test_files_for_period(Date.today, 15.days.ago.to_date)
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
      create_not_empty_test_files_for_period(Date.today, 6.months.ago.to_date)
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "4.months"))
      cleanup.start

      assert_equal 6, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(1.month.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.months.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(3.months.ago.end_of_month.to_date)}")
    end

    def test_start_should_delete_everything_but_the_backups_from_the_last_three_days
      create_not_empty_test_files_for_period(Date.today, 6.months.ago.to_date)
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "0.days"))
      cleanup.start

      assert_equal 5, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
    end

    def test_start_should_not_delete_any_backup_within_this_month_if_last_backup_is_empty
      create_not_empty_test_files_for_period(Date.today - 1.day, 6.months.ago.to_date)
      create_empty_test_files_for_period(Date.today, Date.today)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "4.months"))
      cleanup.start

      assert_equal 13, Dir.entries(test_directory).count

      Date.today.downto(Date.today.beginning_of_month) do |day|
        assert File.exist?("#{test_directory}/#{backup_filename(day)}")
      end

      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 1.month).end_of_month)}")
      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 2.month).end_of_month)}")
      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 3.month).end_of_month)}")
    end

    def test_start_should_not_delete_any_backup_within_this_month_if_last_backup_is_empty_and_we_dont_keep_monthly_backups
      create_not_empty_test_files_for_period("01.07.2018".to_date - 1.day, 6.months.ago.to_date)
      create_empty_test_files_for_period("01.07.2018".to_date, "01.07.2018".to_date)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "0.months"))
      cleanup.start

      assert_equal 4, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename("1.07.2018".to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename("1.07.2018".to_date - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(("1.07.2018".to_date - 1.month).end_of_month)}")
    end

    def test_start_should_correctly_delete_backups_if_last_backup_is_not_empty
      create_not_empty_test_files_for_period(Date.today, 2.years.ago.to_date)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "1.year"))
      cleanup.start

      assert_equal 17, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
      assert File.exist?("#{test_directory}/#{backup_filename(11.months.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.years.ago.end_of_year.to_date)}")
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

      def create_not_empty_test_files_for_period start_date, end_date
        start_date.downto(end_date) do |date|
          FileUtils.touch "#{test_directory}/#{backup_filename(date)}"
          File.open("#{test_directory}/#{backup_filename(date)}", "w") { |file| file.write("not empty") }
        end
      end

      def create_empty_test_files_for_period start_date, end_date
        start_date.downto(end_date) do |date|
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
