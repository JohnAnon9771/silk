$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'silk'

puts "Rendering mockup..."

Silk.render("result.png", size: [800, 600]) do
  layer "base.png"
  layer "overlay.png"
end

puts "Done! Check result.png"

