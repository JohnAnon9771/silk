require_relative "../ast/node"
require_relative "../ast/effects"

module Silk
  module DSL
    class LayerBuilder
      def initialize(layer)
        @layer = layer
      end

      def evaluate(&block)
        instance_eval(&block) if block_given?
      end
      
      # Properties
      def x(value)
        @layer.properties[:x] = value
      end

      def y(value)
        @layer.properties[:y] = value
      end

      def width(value)
        @layer.properties[:width] = value
      end

      def height(value)
        @layer.properties[:height] = value
      end
      
      def fit(value)
        @layer.properties[:fit] = value
      end
      
      def blend(value)
        @layer.properties[:blend] = value
      end
      
      def trim(value)
        @layer.properties[:trim] = value
      end
      
      alias_method :blend_mode, :blend

      def displace(map:, scale: 20, **options)
        effect = AST::DisplacementEffect.new(map: map, scale: scale, **options)
        @layer.add_effect(effect)
      end

      def relight(map:, **options)
        effect = AST::LightingEffect.new(map: map, **options)
        @layer.add_effect(effect)
      end

      def blur(radius:)
        effect = AST::BlurEffect.new(radius: radius)
        @layer.add_effect(effect)
      end

      def grayscale
        effect = AST::GrayscaleEffect.new
        @layer.add_effect(effect)
      end

      def adjust_color(**options)
        effect = AST::ColorAdjustmentEffect.new(**options)
        @layer.add_effect(effect)
      end      
    end
  end
end
