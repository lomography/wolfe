require_relative "test_helper"

class WolfeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wolfe::VERSION
  end

  def test_run_cleanup_should_raise_argument_error_if_file_does_not_exist
    assert_raises ArgumentError do
      Wolfe.run_cleanup "/not/really/a/file"
    end
  end
end
