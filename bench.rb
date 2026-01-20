require "benchmark/ips"
$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "silk"


# Ensure assets are generated
unless File.exist?("base.png")
  Vips::Image.black(1024, 1024, bands: 3).linear([1], [128,128,128]).bandjoin(255).cast(:uchar).write_to_file("base.png")
  Vips::Image.black(500, 500, bands: 3).linear([1], [255,0,0]).bandjoin(255).cast(:uchar).write_to_file("overlay.png")
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("simple_composite") do
    Silk.render("bench_output_simple.png", size: [1024, 1024]) do
      layer "base.png"
      layer "overlay.png", x: 200, y: 200
    end
  end

  x.report("complex_composite") do
    Silk.render("bench_output_complex.png", size: [1024, 1024]) do
      layer "base.png"
      layer "overlay.png", x: 50, y: 50, blend: :multiply
      layer "overlay.png", x: 400, y: 400, width: 200, height: 200, fit: :cover
      layer "overlay.png", x: 600, y: 100, blur: 5
      layer "overlay.png", x: 100, y: 600, grayscale: true
    end
  end

  x.compare!
end

# Cleanup
File.delete("bench_output_simple.png") if File.exist?("bench_output_simple.png")
File.delete("bench_output_complex.png") if File.exist?("bench_output_complex.png")
