require_relative '../effect'

module Silk
  module AST
    module Effects
      class Grayscale < Effect
        def accept(visitor)
          visitor.visit_grayscale_effect(self)
        end
      end
    end
  end
end
