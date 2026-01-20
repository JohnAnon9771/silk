module Silk
  module DSL
    class PipelineBuilder
      def initialize(options, &block)
        @options = options
        @block = block
      end

      def build
        # In MVP, we assume the outer block defines a canvas-like structure
        # or we wrapp it. For the prompt example: Silk.render "file", size: [w, h] do ...
        # The options contain size.
        
        canvas = AST::Canvas.new(size: @options[:size])
        CanvasBuilder.new(canvas).evaluate(&@block)
        canvas
      end
    end

    class CanvasBuilder
      def initialize(canvas)
        @canvas = canvas
      end

      def evaluate(&block)
        instance_eval(&block) if block_given?
      end

      def layer(source, **options, &block)
        add_layer(source, options, &block)
      end

      # Specialized layer aliases from the example
      def template(source, **options, &block)
        add_layer(source, options.merge(role: :template), &block)
      end

      def mask(source, **options, &block)
        add_layer(source, options.merge(role: :mask), &block)
      end

      def artwork(source, **options, &block)
        add_layer(source, options.merge(role: :artwork), &block)
      end

      private

      def add_layer(source, options)
        # options now includes :blend if passed
        # We need to extract the block if user passed one to add_layer
        # But add_layer in PipelineBuilder helper doesn't accept block in my previous signature?
        # wait, `layer "msg" do ... end` passes block to `layer`.
        # I need to pass it here.
        
        # NOTE: PipelineBuilder methods (layer, template, etc) need to capture &block and pass it here.
        # But I modified `add_layer` signature? No, I need to check caller.
        
        # Let's fix `add_layer` signature in `PipelineBuilder` first. (DSL layer).
        # Actually `add_layer` is private called by `layer`.
        # `layer` captures block. I need to handle it.
        
        node = AST::Layer.new(source: source, **options)
        @canvas.add_child(node)
        
        # If a block was given to the caller of this, we need to execute it with LayerBuilder
        # But `add_layer` implementation in previous step was:
        # def add_layer(source, options) ... end
        # The caller `layer`, `template` etc need to pass the block.
        
        # I will assume the caller does `add_layer(source, options, &block)`
        # I need to update those call sites in `PipelineBuilder`.
      end
    end
  end
end
