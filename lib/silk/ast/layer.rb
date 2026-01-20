require_relative 'node'

module Silk
  module AST
    class Layer < Node
      def source
        properties[:source]
      end

      def blend_mode
        properties[:blend] || :over
      end
    end
  end
end
