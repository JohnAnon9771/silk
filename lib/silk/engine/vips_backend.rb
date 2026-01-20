require "vips"

module Silk
  module Engine
    class VipsBackend
      def initialize(canvas)
        @canvas = canvas
        @source_cache = {}
      end

      def call
        width = @canvas.width
        height = @canvas.height
        
        # Create a blank black image with alpha
        # Bands: 3 (RGB). Set interpretation to sRGB.
        background = Vips::Image.black(width, height, bands: 3)
                                .copy(interpretation: :srgb)
                                .bandjoin(255) # Add solid alpha

        # Collect separate arrays for batch composite
        overlays = []
        modes = []
        xs = []
        ys = []

        @canvas.children.each do |layer|
          overlay = load_layer(layer)
          
          # Ensure sRGB
          if overlay.bands >= 3 && overlay.interpretation == :multiband
             overlay = overlay.copy(interpretation: :srgb)
          end

          # 1. Resize if needed
          if layer.width || layer.height
             target_width = layer.width || overlay.width
             target_height = layer.height || overlay.height
             
             size_mode = :both 
             crop_mode = :none
             if layer.fit == :cover
               crop_mode = :centre # Default gravity
             end

             if layer.fit == :fill
                # Vips thumbnail doesn't support 'stretch' easily without crop. 
                # So we use standard resize for 'fill' (stretch).
                scale_x = target_width.to_f / overlay.width
                scale_y = target_height.to_f / overlay.height
                overlay = overlay.resize(scale_x, vscale: scale_y)
             else
                # contain / cover
                overlay = overlay.thumbnail_image(target_width, 
                                                  height: target_height, 
                                                  size: size_mode, 
                                                  crop: crop_mode)
             end
          end

          # 1.5. Apply Effects (Displacement, Lighting, Filters)
          # These must be applied BEFORE compositing onto background
          layer.effects.each do |effect|
            case effect
            when AST::DisplacementEffect
              # Load map logic (simplified)
              map = Vips::Image.new_from_file(effect.map_source)
              scale = effect.scale
              map = map.thumbnail_image(overlay.width, height: overlay.height, size: :force)
              coords = Vips::Image.xyz(overlay.width, overlay.height)
              
              if map.bands == 1
                 map = map.bandjoin(map)
              end
              if map.bands > 2
                 map = map.extract_band(0, n: 2)
              end
              
              displacement = map.cast(:float) * (scale / 255.0)
              distorted_coords = coords + displacement
              overlay = overlay.mapim(distorted_coords)

            when AST::LightingEffect
              map = Vips::Image.new_from_file(effect.map_source)
              map = map.thumbnail_image(overlay.width, height: overlay.height, size: :force)
              if map.bands >= 3 && map.interpretation == :multiband
                 map = map.copy(interpretation: :srgb)
              end
              mode = effect.type == :hard ? :hard_light : :soft_light
              overlay = overlay.composite([map], mode)
              
            when AST::BlurEffect
              overlay = overlay.gaussblur(effect.radius)
              
            when AST::GrayscaleEffect
              if overlay.has_alpha?
                alpha = overlay.extract_band(overlay.bands - 1)
                rgb = overlay.extract_band(0, n: overlay.bands - 1)
                rgb = rgb.colourspace(:b_w)
                overlay = rgb.bandjoin(alpha)
              else
                overlay = overlay.colourspace(:b_w)
              end
              
            when AST::ColorAdjustmentEffect
              gain = effect.contrast
              gain = gain * effect.brightness
              overlay = overlay.linear([gain], [0])
            end
          end

          # Add to batch lists
          overlays << overlay
          modes << map_blend_mode(layer.blend_mode)
          xs << (layer.x || 0)
          ys << (layer.y || 0)
        end
        
        # Batch composite all layers onto background
        return background if overlays.empty?
        
        background.composite(overlays, modes, x: xs, y: ys)
      end

      private

      def map_blend_mode(mode)
        # Map Silk symbols to Vips composite modes
        mode
      end

      def load_layer(layer)
        source = layer.source
        return @source_cache[source] if @source_cache[source]

        # TODO: Handle missing files, etc.
        img = Vips::Image.new_from_file(source)
        
        # Ensure alpha channel exists
        unless img.has_alpha?
          img = img.bandjoin(255)
        end
       
        @source_cache[source] = img
        img
      end
    end
  end
end
