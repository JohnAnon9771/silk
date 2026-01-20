require 'vips'

# Base: Red
base = Vips::Image.black(500, 500, bands: 3)
                  .linear([1], [255, 0, 0])
                  .bandjoin(255)
                  .cast(:uchar)
base.write_to_file("base.png")

# Overlay: Blue
overlay = Vips::Image.black(200, 200, bands: 3)
                     .linear([1], [0, 0, 255])
                     .bandjoin(255) # Opaque to test blend
                     .cast(:uchar)
overlay.write_to_file("blue_square.png")

# Overlay: 50% Grey
grey = Vips::Image.black(200, 200, bands: 3)
                  .linear([1], [128, 128, 128])
                  .bandjoin(255)
                  .cast(:uchar)
grey.write_to_file("grey_square.png")

puts "Assets generated: base.png, blue_square.png, grey_square.png"
