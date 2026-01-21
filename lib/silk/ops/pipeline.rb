require_relative "base"

module Silk
  module Ops
    class Pipeline < Base
      attr_reader :layers, :background_width, :background_height

      def initialize(background_width:, background_height:)
        super(input: nil)
        @background_width = background_width
        @background_height = background_height
        @layers = [] # Array of { op: Op, x: int, y: int, blend: symbol }
      end

      def add_layer(op, x, y, blend)
        @layers << { op: op, x: x, y: y, blend: blend }
      end

      def call(context = nil)
        bg = Vips::Image.black(
          @background_width,
          @background_height,
          bands: 3
        ).copy(interpretation: :srgb).bandjoin(255)

        overlays = []
        modes = []
        xs = []
        ys = []

        @layers.each do |layer_def|
           img = layer_def[:op].call(context)

           # Ensure sRGB
           if img.bands >= 3 && img.interpretation == :multiband
             img = img.copy(interpretation: :srgb)
           end

           overlays << img
           modes << (layer_def[:blend] || :over)
           xs << (layer_def[:x] || 0)
           ys << (layer_def[:y] || 0)
        end

        return bg if overlays.empty?
        bg.composite(overlays, modes, x: xs, y: ys)
      end
    end
  end
end
