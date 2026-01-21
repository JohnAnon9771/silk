require "silk/ast/visitor"
require "silk/ops/base"
require "silk/ops/load"
require "silk/ops/trim"
require "silk/ops/resize"
require "silk/ops/effect_op"
require "silk/ops/pipeline"

module Silk
  module Planner
    class Builder < AST::Visitor
      def build(canvas)
        visit(canvas)
      end

      def visit_canvas(node)
        pipeline = Ops::Pipeline.new(
          background_width: node.width,
          background_height: node.height
        )

        node.children.each do |layer|
          op_tree = visit(layer)

          if op_tree
            pipeline.add_layer(
              op_tree,
              layer.x || 0,
              layer.y || 0,
              layer.blend_mode || :over
            )
          end
        end

        pipeline
      end

      def visit_layer(node)
        # 1. Base Op: Load
        # Apply "Smart Load" optimization eagerly
        load_target_w = nil
        load_target_h = nil
        load_crop = nil

        # If it's a simple resize (no trim before it), we can push to Load
        if !node.trim && (node.width || node.height)
          load_target_w = node.width
          load_target_h = node.height
          load_crop = (node.fit == :cover ? :centre : nil)
        elsif node.trim && (node.width && node.width < 1000)
          # Trim optimization: Load a safe thumbnail first
          load_target_w = node.width * 2
        end

        op = Ops::Load.new(
          node.source,
          target_width: load_target_w,
          target_height: load_target_h,
          crop_mode: load_crop
        )

        # 2. Trim
        op = Ops::Trim.new(input: op) if node.trim

        # 3. Resize
        if node.width || node.height
          op = Ops::Resize.new(
            input: op,
            width: node.width,
            height: node.height,
            fit: node.fit
          )
        end

        # 4. Effects
        node.effects.each do |effect|
          op = Ops::EffectOp.new(input: op, effect_node: effect)
        end

        op
      end
    end
  end
end
