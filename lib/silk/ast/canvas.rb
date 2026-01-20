require_relative 'node'

module Silk
  module AST
    class Canvas < Node
      def width
        properties[:size][0]
      end

      def height
        properties[:size][1]
      end
    end
  end
end
