require_relative "base"

module Silk
  module Ops
    class EffectOp < Base
      EFFECTS = {
        AST::Effects::Blur => ->(img, effect) { img.gaussblur(effect.radius) },
        AST::Effects::ColorAdjustment => ->(img, effect) {
           gain = effect.contrast * effect.brightness
           img.linear([gain], [0])
        },
        AST::Effects::Grayscale => ->(img, effect) { grayscale(img, effect) }
      }.freeze

      attr_reader :effect_node

      def initialize(input:, effect_node:)
        super(input: input)
        @effect_node = effect_node
      end

      def call(context = nil)
        img = @input.call(context)

        EFFECTS[@effect_node] || img
      end

      private

      def grayscale(img, effect)
        if img.has_alpha?
          alpha = img.extract_band(img.bands - 1)
          rgb = img.extract_band(0, n: img.bands - 1)
          rgb.colourspace(:b_w).bandjoin(alpha)
        else
          img.colourspace(:b_w)
        end
      end
    end
  end
end
