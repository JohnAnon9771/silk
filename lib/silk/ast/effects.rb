require_relative 'node'

module Silk
  module AST
    class Effect < Node
      def map_source
        properties[:map]
      end
    end

    class DisplacementEffect < Effect
      def scale
        properties[:scale] || 20
      end
    end

    class LightingEffect < Effect
      def type
        properties[:type] || :ambient
      end
      
      def strength
        properties[:strength] || 1.0
      end
    end

    class BlurEffect < Effect
      def radius
        properties[:radius] || 0
      end
    end

    class GrayscaleEffect < Effect
    end

    class ColorAdjustmentEffect < Effect
      def brightness
        properties[:brightness] || 1.0
      end
      
      def contrast
        properties[:contrast] || 1.0
      end
    end
  end
end
