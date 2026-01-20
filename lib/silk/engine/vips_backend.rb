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

          # 1. Resize if needed
          if layer.width || layer.height
             # Use Vips thumbnail if we have a file source (it's faster/better), 
             # but we loaded 'overlay' as an Image object. 
             # Vips::Image#thumbnail_image is available for in-memory images too.
             
             target_width = layer.width || overlay.width
             target_height = layer.height || overlay.height
             
             # Decode 'fit' mode to Vips size/crop options
             # Silk defaults: fit: :contain (default Vips behavior), :cover, :fill
             
             size_mode = :down # Default to downscaling only? Or :both? Vips default is :down.
             # If user specifies size, they probably want that size even if upscaling.
             size_mode = :both 

             crop_mode = :none
             if layer.fit == :cover
               crop_mode = :centre # Default gravity
               # Todo: Map layer.gravity to Vips gravity (:centre, :north, etc)
             end

             if layer.fit == :fill
                # Vips thumbnail doesn't support 'stretch' easily without crop. 
                # So we use standard resize for 'fill' (stretch).
                scale_x = target_width.to_f / overlay.width
                scale_y = target_height.to_f / overlay.height
                overlay = overlay.resize(scale_x, vscale: scale_y)
             else
                # Use thumbnail_image for :contain (default) and :cover
                # height is mandatory for thumbnail_image if we want specific box?
                # thumbnail_image(width, height: ..., size: ..., crop: ...)
                
                overlay = overlay.thumbnail_image(target_width, 
                                                  height: target_height, 
                                                  size: size_mode, 
                                                  crop: crop_mode)
             end
          end

          # 2. Position (Embed in canvas-sized buffer)
          # We need to place 'overlay' at x,y onto a transparent canvas of size @canvas.width/height
          # AND then composite that onto bg? 
          # OR just composite at offset?
          # Vips `composite` aligns to 0,0 of the inputs.
          # So strictly, we should embed overlay into a full-size transparent buffer.
          
          # Optimization: If x=0, y=0 and size matches, valid. 
          # Otherwise embed.
          
          if layer.x != 0 || layer.y != 0 || overlay.width != @canvas.width || overlay.height != @canvas.height
            # embed(x, y, width, height, extend: :background, background: [0,0,0,0])
            # We want the resulting image to be @canvas.width x @canvas.height
            # The 'overlay' is placed at x,y inside this box.
            
            # Vips embed: x, y, width, height.
            # x, y are position of the input image relative to the output?
            # No, embed expands the canvas. 
            # documentation: "embed image in a larger image"
            # embed(x, y, width, height)
            # x, y: position of the old image within the new image.
            
            overlay = overlay.embed(layer.x, layer.y, @canvas.width, @canvas.height, 
                                    extend: :background, background: [0,0,0,0])
          end

          mode = map_blend_mode(layer.blend_mode)
          bg.composite([overlay], mode)
        end
        
        final_image
      end

      private

      def map_blend_mode(mode)
        # Map Silk symbols to Vips composite modes
        # Vips uses :VIPS_BLEND_MODE_... but in ruby-vips it's usually just the symbol or int.
        # Check Vips::BlendMode enum or string.
        # Actually composite accepts integers/enums. 
        # :over is standard.
        # :multiply -> :multiply
        # :screen -> :screen
        # :overlay -> :overlay
        # etc. Libvips mostly matches standard names.
        
        mode
      end

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
