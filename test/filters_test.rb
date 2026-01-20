require "test_helper"

class FiltersTest < Minitest::Test
  def setup
    @output = "test_filters.png"
  end
  
  def teardown
    File.delete(@output) if File.exist?(@output)
  end

  def test_blur
    Silk.render(@output, size: [200, 200]) do
      layer "test/assets/base.png" do
        blur radius: 5
      end
    end
    assert File.exist?(@output)
  end
  
  def test_grayscale
    Silk.render(@output, size: [200, 200]) do
      layer "test/assets/base.png" do
        grayscale
      end
    end
    assert File.exist?(@output)
    # Could check bands count or pixel color (should be gray = r==g==b)
  end
end
