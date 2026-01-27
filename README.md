<p align="center">
  <img src="assets/logo.png" width="240" alt="Silk Logo">
</p>

<h1 align="center">Silk 🧶</h1>

<p align="center">
  <strong>Intelligent, High-Performance Image Processing for Ruby.</strong>
</p>

<p align="center">
  <a href="https://rubygems.org/gems/silk"><img src="https://img.shields.io/gem/v/silk.svg" alt="Gem Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/JohnAnon9771/silk/actions"><img src="https://img.shields.io/badge/tests-passing-success.svg" alt="Tests Status"></a>
</p>

---

Silk is a modern wrapper around `libvips` that introduces a **Smart DSL** for composing images. It focuses on performance via AST optimization and provides a superior developer experience with declarative syntax and reusable styles.

## 🚀 Key Features

- **High Performance**: Built on `libvips` with a custom Batch Composition engine that flattens operations into a single efficient pipeline.
- **Hierarchical Groups**: Nest layers and groups to create complex layouts with shared effects.
- **Intelligent DSL**: Declarative, block-based syntax. Define properties naturally without complex argument lists.
- **AST Optimizer**: An intermediate layer that prunes invisible layers and pre-calculates geometry before rendering.
- **Extensible Effects**: Dynamic registry to add your own image processing strategies.

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'silk'
```

And then execute:

```bash
bundle install
```

## 🛠 Usage

### 1. Generating Images

Silk offers two ways to get your results: `render` (write to file) and `generate` (get a `Vips::Image` object).

#### Render to file

```ruby
Silk.render("output.png", size: [1200, 630]) do
  layer "background.jpg"
end
```

#### Generate in-memory (Web Servers / Testing)

```ruby
# Returns a Vips::Image object
image = Silk.generate(size: [1200, 630]) do
  layer "background.jpg"
end

# Get binary buffer for HTTP response or S3
buffer = image.write_to_buffer(".png")
```

### 2. Hierarchical Groups

Group layers to apply effects or positioning to a set of nodes collectively.

```ruby
Silk.render("banner.png", size: [800, 400]) do
  group x: 50, y: 50 do
    layer "icon.png", width: 50
    layer "text.png", x: 60

    # Apply blur to the entire group
    blur radius: 2
  end
end
```

### 3. The Smart DSL

Forget about complex argument lists. Describe your image layout naturally:

```ruby
require 'silk'

Silk.render("output.png", size: [1200, 630]) do
  # Background
  layer "background.jpg" do
    fit :cover
    blur radius: 10
  end

  # Overlay
  layer "avatar.png" do
    x :center
    y :center
    width "20%"
    trim true # Auto-crop transparent borders
  end
end
```

### 4. Reusable Styles

Define common looks and apply them anywhere.

```ruby
# Define a style
Silk.define_style :hero_layer do
  x 50
  y 100
  blend :overlay
end

Silk.render("post.png", size: [1000, 1000]) do
  layer "texture.png" do
    use :hero_layer # Apply the style
    width 500       # Override or extend
  end
end
```

### 5. Custom Effects & Registry

Silk is extensible. You can register your own `libvips` processors:

```ruby
# Register a custom effect
Silk.register_effect(MyCustomEffectClass, ->(img, effect_node) {
  img.my_vips_operation(effect_node.param)
})
```

## ⚡ Performance

Silk is designed for scale. Leveraging `libvips`' streaming architecture and our proprietary AST optimization, Silk delivers exceptional throughput:

| Complexity                    | Throughput (M1) |
| :---------------------------- | :-------------- |
| Simple Composites             | ~70 images/sec  |
| Complex (5+ layers + effects) | ~60 images/sec  |

## 🗺 Roadmap

- [ ] Full support for relative geometry (`%`, `vh`, `vw`)
- [ ] Rounded corners and masking
- [ ] SVG support as layers
- [ ] Smart Saliency Masking (Background Removal)

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
