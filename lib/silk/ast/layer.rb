require_relative 'node'

module Silk
  module AST
    class Layer < Node
      def source
        properties[:source]
      end
    end
  end
end
