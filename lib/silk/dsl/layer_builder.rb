module Silk
  module DSL
    class LayerBuilder
      def initialize(layer)
        @layer = layer
      end

      def evaluate(&block)
        instance_eval(&block) if block_given?
      end

      def displace(map:, scale: 20, **options)
        effect = AST::DisplacementEffect.new(map: map, scale: scale, **options)
        @layer.add_effect(effect)
      end

      def relight(map:, **options)
        effect = AST::LightingEffect.new(map: map, **options)
        @layer.add_effect(effect)
      end
      
      # Allow setting properties inside the block too? 
      # e.g. width 100
      # For now, let's strictly keep to adding effects and children (if we had nested layers).
    end
  end
end
