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

      def layer(source, **options)
        # For simplicity in MVP, we might treat 'template' 'artwork' as layers
        # But let's support generic 'layer' too.
        # If user uses 'template', we'll likely alias it or the user prompt implies explicit methods.
        # The user prompt example had: template "...", mask "...", artwork "..."
        # Let's support those.
        
        add_layer(source, options)
      end

      # Specialized layer aliases from the example
      def template(source, **options)
        add_layer(source, options.merge(role: :template))
      end

      def mask(source, **options)
        # Mask usually applies to previous layer or is a standalone alpha map? 
        # In the example: mask "print_area.png". It looks like a global mask or a layer.
        # Let's treat it as a layer for now, or a special node.
        # Architecture said Mask is a node.
        # But for MVP let's just add it as a child.
        add_layer(source, options.merge(role: :mask))
      end

      def artwork(source, **options)
        add_layer(source, options.merge(role: :artwork))
      end

      private

      def add_layer(source, options)
        # We need a Layer node. I should create it next.
        # options now includes :blend if passed
        node = AST::Layer.new(source: source, **options)
        @canvas.add_child(node)
      end
    end
  end
end
