module Silk
  module AST
    class Optimizer
      def initialize(canvas)
        @canvas = canvas
      end

      def call
        # Start with canvas dimensions
        w = @canvas.width
        h = @canvas.height
        
        @canvas.children.map! { |child| optimize_node(child, w, h) }
        @canvas.children.compact!
        @canvas
      end

      private

      def optimize_node(node, parent_width, parent_height)
        # Deep copy or modify? ideally return new tree.
        # For MVP, let's modify in place or just return the node if no changes.
        
        # Optimize children first
        node.children.map! { |child| optimize_node(child, parent_width, parent_height) }
        node.children.compact! # Remove pruned nodes

        # Apply node-specific optimizations
        case node
        when Layer
          optimize_layer(node, parent_width, parent_height)
        when Canvas
           # Canvas defines the root dimensions for its children
           # Children handled above via recursion on node.children
           nil 
        else
          node
        end
      end
      
      def optimize_layer(layer, parent_w, parent_h)
        # Resolve Geometry
        layer.properties[:x] = resolve_dim(layer.x, parent_w)
        layer.properties[:y] = resolve_dim(layer.y, parent_h)
        layer.properties[:width] = resolve_dim(layer.width, parent_w)
        layer.properties[:height] = resolve_dim(layer.height, parent_h)
        
        # Prune if width/height are 0 (and explicitly set)
        return nil if layer.width == 0 || layer.height == 0
        
        layer
      end
      
      def resolve_dim(value, total)
        return value unless value.is_a?(String) && value.end_with?("%")
        
        percent = value.to_f / 100.0
        (total * percent).round
      end
    end
  end
end
