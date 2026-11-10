require_relative "../test_helper"

module Wolfe
  class TimespanFromConfigurationTest < Minitest::Test
    def test_supports_singular_and_plural_units
      assert_equal 1.day, TimespanFromConfiguration.new("1.day").timespan
      assert_equal 3.days, TimespanFromConfiguration.new("3.days").timespan
      assert_equal 1.week, TimespanFromConfiguration.new("1.week").timespan
      assert_equal 2.weeks, TimespanFromConfiguration.new("2.weeks").timespan
      assert_equal 1.month, TimespanFromConfiguration.new("1.month").timespan
      assert_equal 2.months, TimespanFromConfiguration.new("2.months").timespan
      assert_equal 1.year, TimespanFromConfiguration.new("1.year").timespan
    end

    def test_rejects_hours
      assert_raises ArgumentError do
        TimespanFromConfiguration.new("12.hours")
      end
    end
  end
end
