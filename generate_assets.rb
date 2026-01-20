require 'vips'

# Create a red square 500x500
# Linear `a * img + b`. 
# We want Red (255,0,0). So start with black (0), multiply by 1, add [255, 0, 0].
base = Vips::Image.black(500, 500, bands: 3)
                  .linear([1], [255, 0, 0])
                  .bandjoin(255) # Add alpha: 255 (opaque)
                  .cast(:uchar)
base.write_to_file("base.png")

# Create a blue circle (approx) or smaller square 200x200
overlay = Vips::Image.black(200, 200, bands: 3)
                     .linear([1], [0, 0, 255])
                     .bandjoin(128) # Add alpha: 128 (semi-transparent)
                     .cast(:uchar)
overlay.write_to_file("overlay.png")


puts "Assets generated: base.png, overlay.png"
