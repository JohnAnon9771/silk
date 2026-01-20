$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'silk'

puts "Rendering blend mode test..."

Silk.render("blend_test.png", size: [600, 600]) do
  # Red background
  layer "base.png"

  # Blue square with Multiply (Red * Blue = Black)
  # Position? For now 0,0.
  layer "blue_square.png", blend: :multiply

  # Grey square with Screen (Should lighten)
  # We can't position yet, so it will cover the blue one if drawn later.
  # Let's verify 'multiply' first.
end

puts "Done! Check blend_test.png"
