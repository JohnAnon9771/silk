require "vips"
require "zeitwerk"
require "silk/version"

module Silk
  class Error < StandardError; end

  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect(
    "dsl" => "DSL",
    "ast" => "AST"
  )
  loader.setup

  class << self
    def render(output_path, **options, &block)
      # Entry point for the DSL
      canvas = DSL::PipelineBuilder.new(options, &block).build
      # For MVP: Direct AST -> Engine execution
      output_image = Engine::VipsBackend.new(canvas).call
      output_image.write_to_file(output_path)
    end
  end
end
