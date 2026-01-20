require "vips"

module Silk
  module Engine
    class VipsBackend
      def initialize(canvas)
        @canvas = canvas
      end

      def call
        # Initialize background (transparent or colored)
        # Vips logic: Create black image, join with alpha?
        # For simplicity MVP: Black background
        width = @canvas.width
        height = @canvas.height
        
        # Create a blank black image with alpha
        # Bands: 3 (RGB). Set interpretation to sRGB.
        background = Vips::Image.black(width, height, bands: 3)
                                .copy(interpretation: :srgb)
                                .bandjoin(255) # Add solid alpha

        # Composite layers
        final_image = @canvas.children.reduce(background) do |bg, layer|
          overlay = load_layer(layer)
          
          # Center the overlay for now, or just 0,0
          # Composite expects array of images and mode.
          # We need to handle resizing/placement later.
          # For MVP: just composite on top (0,0)
          
          # Ensure overlay is treated as srgb (if it's 3 or 4 bands)
          # If inputs differ in interpretation, Vips tries to convert.
          # 'multiband' -> 'srgb' conversion fails if it doesn't know how.
          if overlay.bands >= 3 && overlay.interpretation == :multiband
             overlay = overlay.copy(interpretation: :srgb)
          end

          bg.composite([overlay], :over)
        end
        
        final_image
      end

      private

      def load_layer(layer)
        source = layer.source
        # TODO: Handle missing files, etc.
        img = Vips::Image.new_from_file(source)
        
        # Ensure alpha channel exists
        unless img.has_alpha?
          img = img.bandjoin(255)
        end
        
        img
      end
    end
  end
end
