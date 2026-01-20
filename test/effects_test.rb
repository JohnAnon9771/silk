require "test_helper"

class EffectsTest < Minitest::Test
  def setup
    @output = "test_effects.png"
    # Create a grid pattern for displacement test
    unless File.exist?("test/assets/grid.png")
       # Simple 200x200 grey
       grid = Vips::Image.black(200, 200, bands: 3).linear([1], [128,128,128]).bandjoin(255).cast(:uchar)
       grid.write_to_file("test/assets/grid.png")
    end
    
    # Create a displacement map (gradient)
    unless File.exist?("test/assets/disp_map.png")
       # Simple gradient
       Vips::Image.black(200, 200, bands: 1).linear([1], [50]).cast(:uchar).write_to_file("test/assets/disp_map.png")
    end
  end

  def teardown
    File.delete(@output) if File.exist?(@output)
  end

  def test_displacement
    Silk.render(@output, size: [200, 200]) do
      layer "test/assets/grid.png" do
        displace map: "test/assets/disp_map.png", scale: 20
      end
    end
    
    assert File.exist?(@output)
    # Validate it runs. Visual check needed for correctness.
  end
  
  def test_lighting
    Silk.render(@output, size: [200, 200]) do
      layer "test/assets/base.png" do
        relight map: "test/assets/disp_map.png", type: :soft
      end
    end
    
    assert File.exist?(@output)
  end
end
