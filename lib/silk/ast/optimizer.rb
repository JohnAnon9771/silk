require_relative 'visitor'

module Silk
  module AST
    class Optimizer < Visitor
      def initialize(canvas)
        @canvas = canvas
        @width_stack = []
        @height_stack = []
      end

      def call
        visit(@canvas)
        @canvas
      end

      def visit_canvas(node)
        @width_stack.push(node.width)
        @height_stack.push(node.height)
        
        # Optimize children
        # We use map! to allow replacing nodes (though prune is different)
        # Standard visit iterates. Here we need to mutate the list.
        
        node.children.map! do |child| 
          res = visit(child)
          # If visit returns :prune (or nil), we should handle it. 
          # But map! replaces. So let's return the node if ok, nil if prune.
          res
        end
        node.children.compact!

        @width_stack.pop
        @height_stack.pop
        
        node
      end

      def visit_layer(node)
        parent_w = @width_stack.last
        parent_h = @height_stack.last

        # Resolve Geometry
        node.properties[:x] = resolve_dim(node.x, parent_w)
        node.properties[:y] = resolve_dim(node.y, parent_h)
        node.properties[:width] = resolve_dim(node.width, parent_w)
        node.properties[:height] = resolve_dim(node.height, parent_h)

        # Recursively visit children (if layers had children)
        # node.children... 

        # Prune if width/height are 0 (and explicitly set)
        return nil if node.width == 0 || node.height == 0

        # Optimize effects?
        # node.effects.each { |e| visit(e) }

        node
      end

      private
      
      def resolve_dim(value, total)
        return value unless value.is_a?(String) && value.end_with?("%")
        
        percent = value.to_f / 100.0
        (total * percent).round
      end
    end
  end
end