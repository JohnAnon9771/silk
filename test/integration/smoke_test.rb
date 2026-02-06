require "test_helper"

class SilkTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Silk::VERSION
  end
end
