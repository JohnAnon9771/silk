require_relative 'node'

module Silk
  module AST
    class Effect < Node
      def map_source
        properties[:map]
      end

      def accept(visitor)
        visitor.visit_effect(self)
      end
    end

    class DisplacementEffect < Effect
      def scale
        properties[:scale] || 20
      end

      def accept(visitor)
        visitor.visit_displacement_effect(self)
      end
    end

    class LightingEffect < Effect
      def type
        properties[:type] || :ambient
      end
      
      def strength
        properties[:strength] || 1.0
      end

      def accept(visitor)
        visitor.visit_lighting_effect(self)
      end
    end

    class BlurEffect < Effect
      def radius
        properties[:radius] || 0
      end

      def accept(visitor)
        visitor.visit_blur_effect(self)
      end
    end

    class GrayscaleEffect < Effect
      def accept(visitor)
        visitor.visit_grayscale_effect(self)
      end
    end

    class ColorAdjustmentEffect < Effect
      def brightness
        properties[:brightness] || 1.0
      end
      
      def contrast
        properties[:contrast] || 1.0
      end

      def accept(visitor)
        visitor.visit_color_adjustment_effect(self)
      end
    end
  end
end
