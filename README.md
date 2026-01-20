# Silk 🧶

<p align="center">
  <img src="assets/logo.png" width="200" alt="Silk Logo">
</p>

**Intelligent, High-Performance Image Processing for Ruby.**

Silk is a modern wrapper around `libvips` that introduces a **Smart DSL** for composing images. It focuses on performance (via batch processing and AST optimization) and developer experience (declarative syntax and reusable styles).

## Key Features

- **🚀 High Performance**: Built on `libvips` with a custom Batch Composition engine that flattens operations into a single efficient pipeline. Handles 4K+ images with ease.
- **🧠 Intelligent DSL**: Declarative, block-based syntax. Define properties naturally.
- **📐 Smart Geometry**: Support for relative values (e.g., `width "50%"`, `x :center`). _(Partial support implemented)_
- **🎨 Reusable Styles**: Define `styles` (macros) once and apply them across your layouts.
- **⚡ AST Optimizer**: An intermediate layer that prunes invisible layers and pre-calculates geometry before rendering.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'silk'
```

And then execute:

```bash
$ bundle install
```

## Usage

### 1. The Smart DSL

Forget about complex argument lists. Describe your image layout naturally:

```ruby
require 'silk'

Silk.render("output.png", size: [1200, 630]) do
  # Background
  layer "background.jpg" do
    fit :cover
    blur radius: 10
  end

  # overlay
  layer "avatar.png" do
    x 50
    y 50
    width 150
    height 150
    round_corner 75 # coming soon
    trim true # Auto-crop transparent borders
  end
end
```

### 2. Reusable Styles

Define common looks and apply them anywhere.

```ruby
# Define a style
Silk.define_style :hero_text do
  x 50
  y 100
  blend :overlay
end

Silk.render("post.png", size: [1000, 1000]) do
  layer "texture.png" do
    use :hero_text # Apply the style
    width 500      # Override or extend
  end
end
```

### 3. Pipeline Optimization

Silk doesn't just run commands blindly. It builds an Abstract Syntax Tree (AST), optimizes it, and then executes.

- **Relative Geometry**: _Coming soon_ (e.g., `width "50%"`).
- **Pruning**: Layers with `0` width or height are removed from the pipeline automatically.
- **Batching**: All composition impacts are batched into a single `libvips` composite call for maximum speed.

## Performance

Silk is designed to be fast. In our benchmarks (M2 Pro), Silk achieves:

- **~65 images/sec** for simple composites.
- **~55 images/sec** for complex composites (5+ layers, blends, effects).
- **Efficient Memory Usage**: Thanks to libvips' streaming architecture.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
