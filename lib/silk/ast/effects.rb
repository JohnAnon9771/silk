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
        # Support scalar or [x, y]
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
  end
end
