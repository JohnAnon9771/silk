module Silk
  module AST
    class Node
      attr_reader :children, :properties

      def initialize(properties = {})
        @properties = properties
        @children = []
      end

      def add_child(node)
        @children << node
        node
      end
    end
  end
end
