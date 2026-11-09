require_relative "../test_helper"

module Wolfe

  class CleanupTest < Minitest::Test

    def setup
      Dir.mkdir(test_directory) unless Dir.exist?(test_directory)
    end

    def teardown
      Timecop.return
      FileUtils.remove_dir(test_directory, true) if Dir.exist?(test_directory)
    end

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
        Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "5.days", "Dir.exist?('/tmp')"))
      end
    end

    #
    # actual cleanup
    #

    def test_start_should_correctly_delete_daily_backups
      Timecop.freeze(2021, 6, 20)
      create_not_empty_test_files_for_period(Date.today, 15.days.ago.to_date)
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "1.year"))
      cleanup.start

      assert_equal 5, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
    end

    def test_start_should_correctly_delete_monthly_backups
      Timecop.freeze(2021, 06, 15)
      create_not_empty_test_files_for_period(Date.today, 5.months.ago.to_date)
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "4.months"))
      cleanup.start

      assert_equal 7, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(1.month.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.months.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(3.months.ago.end_of_month.to_date)}")
      # the month straddling the monthly cutoff keeps its last backup
      assert File.exist?("#{test_directory}/#{backup_filename(4.months.ago.end_of_month.to_date)}")
    end

    def test_start_should_delete_everything_but_the_backups_from_the_last_three_days
      Timecop.freeze(2021, 6, 15)

      create_not_empty_test_files_for_period(Date.today, 6.months.ago.to_date)
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "0.days"))
      cleanup.start

      assert_equal 5, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
    end

    def test_start_should_not_delete_any_backup_within_this_month_if_last_backup_is_empty
      Timecop.freeze(2021, 6, 15)

      create_not_empty_test_files_for_period(Date.today - 1.day, 6.months.ago.to_date)
      create_empty_test_files_for_period(Date.today, Date.today)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "4.months"))
      cleanup.start

      Date.today.downto(Date.today.beginning_of_month) do |day|
        assert File.exist?("#{test_directory}/#{backup_filename(day)}")
      end

      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 1.month).end_of_month)}")
      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 2.month).end_of_month)}")
      assert File.exist?("#{test_directory}/#{backup_filename((Date.today - 3.month).end_of_month)}")
    end

    def test_start_should_not_delete_any_backup_within_this_month_if_last_backup_is_empty_and_we_dont_keep_monthly_backups
      Timecop.freeze(2024, 7, 1)

      create_not_empty_test_files_for_period(Date.today - 1.day, Date.today - 6.months)
      create_empty_test_files_for_period(Date.today, Date.today)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "1.days", "0.months"))
      cleanup.start

      assert_equal 4, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
    end

    def test_start_should_correctly_delete_backups_if_last_backup_is_not_empty
      Timecop.freeze(2021, 6, 15)

      create_not_empty_test_files_for_period(Date.today, 2.years.ago.to_date)

      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "1.year"))
      cleanup.start

      assert_equal 18, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day)}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days)}")
      assert File.exist?("#{test_directory}/#{backup_filename(11.months.ago.end_of_month.to_date)}")
      # the month straddling the monthly cutoff keeps its last backup
      assert File.exist?("#{test_directory}/#{backup_filename(12.months.ago.end_of_month.to_date)}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.years.ago.end_of_year.to_date)}")
    end

    #
    # suffixed filenames and digits in paths
    #

    def test_start_should_delete_suffixed_backups_without_monthly_backups
      Timecop.freeze(2021, 6, 15)
      create_not_empty_test_files_for_period(Date.today, 2.months.ago.to_date, suffix: ".age")
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}.age", "3.days", "0.months"))
      cleanup.start

      assert_equal 5, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today, suffix: '.age')}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 1.day, suffix: '.age')}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days, suffix: '.age')}")
    end

    def test_start_should_delete_suffixed_backups_when_keeping_monthly_backups
      Timecop.freeze(2021, 6, 15)
      create_not_empty_test_files_for_period(Date.today, 2.months.ago.to_date, suffix: ".age")
      cleanup = Cleanup.new(configuration(test_directory, "test_backup-%{year}-%{month}-%{day}-%{hour}.age", "3.days", "1.year"))
      cleanup.start

      assert_equal 7, Dir.entries(test_directory).count
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today, suffix: '.age')}")
      assert File.exist?("#{test_directory}/#{backup_filename(Date.today - 2.days, suffix: '.age')}")
      refute File.exist?("#{test_directory}/#{backup_filename(Date.today - 10.days, suffix: '.age')}")
      assert File.exist?("#{test_directory}/#{backup_filename(1.month.ago.end_of_month.to_date, suffix: '.age')}")
      assert File.exist?("#{test_directory}/#{backup_filename(2.months.ago.end_of_month.to_date, suffix: '.age')}")
    end

    def test_start_should_ignore_digits_in_the_path
      Timecop.freeze(2021, 6, 15)
      dir = File.join(test_directory, "app2-docker")
      Dir.mkdir(dir)
      create_not_empty_test_files_for_period(Date.today, 10.days.ago.to_date, dir: dir)
      cleanup = Cleanup.new(configuration(dir, "test_backup-%{year}-%{month}-%{day}-%{hour}", "3.days", "0.months"))
      cleanup.start

      assert_equal 5, Dir.entries(dir).count
      assert File.exist?("#{dir}/#{backup_filename(Date.today)}")
      assert File.exist?("#{dir}/#{backup_filename(Date.today - 2.days)}")
    end

    private

      def create_not_empty_test_files_for_period(start_date, end_date, suffix: "", dir: test_directory)
        start_date.downto(end_date) do |date|
          File.write("#{dir}/#{backup_filename(date, suffix: suffix)}", "not empty")
        end
      end

      def create_empty_test_files_for_period(start_date, end_date, suffix: "", dir: test_directory)
        start_date.downto(end_date) do |date|
          FileUtils.touch "#{dir}/#{backup_filename(date, suffix: suffix)}"
        end
      end

      def test_directory
        File.join(File.expand_path(File.join(__dir__, 'tmp')))
      end

      def backup_filename(date, suffix: "")
        "test_backup-%04d-%02d-%02d-10%s" % [date.year, date.month, date.day, suffix]
      end

      def configuration(path, filename, day_timespan, month_timespan)
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
