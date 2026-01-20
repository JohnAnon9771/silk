$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "silk"
require "minitest/autorun"
require "vips"

module TestHelper
  def self.generate_assets
    # Ensure assets exist for tests
    unless File.exist?("base.png")
      Vips::Image.black(500, 500, bands: 3)
                 .linear([1], [255, 0, 0])
                 .bandjoin(255)
                 .cast(:uchar)
                 .write_to_file("base.png")
    end

    unless File.exist?("blue_square.png")
      Vips::Image.black(200, 200, bands: 3)
                 .linear([1], [0, 0, 255])
                 .bandjoin(255)
                 .cast(:uchar)
                 .write_to_file("blue_square.png")
    end
  end
end

TestHelper.generate_assets
