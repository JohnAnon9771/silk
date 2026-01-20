require_relative "test_helper"

class TrimTest < Minitest::Test
  def setup
    # ensure_assets_exist # Not needed, we create our own source
    
    # Create an image with a central red square and transparent borders
    # 500x500 image, 100x100 red square in middle
    @trim_source = "trim_test_source.png"
    
    @trim_source = "trim_test_source.png"
    
    # Red square 100x100
    square = Vips::Image.black(100, 100, bands: 3).linear([1], [255,0,0]).bandjoin(255)
    
    # Embed square in center
    final = square.embed(200, 200, 500, 500, extend: :background, background: [0,0,0,0])
    final.write_to_file(@trim_source)
  end

  def teardown
    File.delete(@trim_source) if File.exist?(@trim_source)
    File.delete("output_trim.png") if File.exist?("output_trim.png")
    File.delete("output_no_trim.png") if File.exist?("output_no_trim.png")
  end

  def test_trim_enabled
    # Render with trim. Resulting image should be the canvas size, but the overlay 
    # should have been trimmed before placement. 
    # If we place it at 0,0, it should be the 100x100 square at 0,0.
    # If we didn't trim, it would be the 500x500 image at 0,0 (centering the square at 200,200).
    
    Silk.render("output_trim.png", size: [200, 200]) do
      layer "trim_test_source.png", trim: true, x: 0, y: 0
    end
    
    output = Vips::Image.new_from_file("output_trim.png")
    
    # Check pixel at 0,0. 
    # If trimmed: it should be the red square top-left corner (red).
    # If not trimmed: it would be transparent border.
    
    pixel = output.getpoint(0, 0)
    # Red is [255, 0, 0, 255]
    assert_equal [255, 0, 0, 255], pixel
  end

  def test_trim_disabled
    Silk.render("output_no_trim.png", size: [200, 200]) do
      layer "trim_test_source.png", trim: false, x: 0, y: 0
    end
    
    output = Vips::Image.new_from_file("output_no_trim.png")
    
    # Untrimmed image has transparent border at 0,0
    pixel = output.getpoint(0, 0)
    # Transparent/Black [0,0,0,255] (since we composite on black background in engine, but wait...
    # Engine creates black background with alpha 255?
    # background = Vips::Image.black(width, height, bands: 3).copy(interpretation: :srgb).bandjoin(255)
    # So background is solid black.
    # Our image has transparent border.
    # Composite: Over. Transparent over Black -> Black.
    
    assert_equal [0, 0, 0, 255], pixel
  end
end
