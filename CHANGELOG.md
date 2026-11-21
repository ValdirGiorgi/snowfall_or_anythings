# Changelog

All notable changes to this project will be documented in this file.

## 0.0.9

### Fixed
- The library no longer imports `package:flutter/material.dart`, which is deprecated in newer Flutter versions (Material is moving to its own package). It now only depends on `package:flutter/widgets.dart`. This restores the full static analysis score on pub.dev
- The default `particleColor` is now written as `Color(0xFFFFFFFF)`, the same value as `Colors.white` (no behavior change)
- The logo is the main image on the pub.dev page again (it is now the first screenshot)

## 0.0.8

### Added
- `particleVariants` parameter and `ParticleVariant` class: up to 5 kinds of particles falling together (built-in shapes and/or widgets), each with its own share (`weight`), color, size and speed
- `Particle.variantIndex` so custom painters can draw each variant differently
- `SnowfallOrAnythings.maxParticleVariants` constant
- Example app rebuilt: gallery with live previews, playground with every parameter, Christmas mix with percentages, seasonal presets, overlay, tappable widget particles and a custom painter using `variantIndex`
- Example app also runs as a live web demo at https://snowfall.valdir.dev.br, with an introduction, About page and a link to the article on how the package was built
- README rewritten with GIFs, recipes (snow, hearts, leaves, rain, stars, confetti) and API tables
- `maxFps` parameter to cap the animation frame rate (`null` follows the display refresh rate)
- `Particle.advance(width, height, delta)` for time-based movement (`update` still works and calls it with `delta = 1.0`)
- Optional `repaint` parameter on all built-in painters, so they repaint without being recreated on every frame
- Basic widget tests

### Fixed
- Falling speed no longer depends on the display refresh rate (120 Hz displays were twice as fast)
- `frameRateMs` had no effect. It is now deprecated in favor of `maxFps`; values other than the default `16` are converted to a frame-rate cap for compatibility
- Particles now wrap inside the widget area instead of the whole screen size
- Changing parameters at runtime (`numberOfParticles`, `particleColor`, `particleSize`, `particleSpeed`) is now applied without needing a `Key`
- Painter modes no longer block taps on widgets below the animation
- Particles are no longer created while the widget has an empty size (first frame on Android), which made them start bunched together
- Particles drawn by painters are now clipped to the widget area (they could be drawn over neighboring widgets)
- Particles enter from above the top edge and leave fully through the bottom edge (no more popping), and wrap horizontally when drifting out of the sides
- `shouldRepaint` in built-in painters compared the same mutable objects and never detected changes; repaints are now driven by the `repaint` listenable
- Minimum Flutter version set to 3.29.0 (`Color.withValues` was already required)

### Performance
- Built-in painters repaint through a `Listenable` instead of rebuilding the widget tree on every frame
- Widget particles are positioned with a `Flow` at paint time (no per-frame rebuild/relayout)
- Wrapped in a `RepaintBoundary` to isolate repaints from the rest of the screen
- Single shared `Random` instance and reused `Paint` objects in `LeafParticlePainter`

### Deprecated
- `SnowfallOrAnythings.frameRateMs`: use `maxFps`
- `ParticlePainter`: use `CircularParticlePainter`

## 0.0.7

### Added
- New particle types for greater versatility:
  - `ParticleType.star` - 5-pointed star particles with rotation
  - `ParticleType.heart` - Heart-shaped particles using Bézier curves
  - `ParticleType.leaf` - Realistic leaf particles with central and side veins
  - `ParticleType.raindrop` - Teardrop/raindrop-shaped particles
- New painters: `StarParticlePainter`, `HeartParticlePainter`, `LeafParticlePainter`, `RaindropParticlePainter`
- New example page demonstrating all particle types with color picker and size slider

### Fixed
- **Bug fix**: `particleColor` now works correctly for snowflake particles (was hardcoded to white)

### Changed
- Refactored `SnowflakeParticlePainter` to use particle color instead of hardcoded color
- Updated particle type selection to use Dart 3 switch expression for cleaner code
- Added `hashCode` and `==` operators to `Particle` class for proper comparison
- Unified `ParticlePainter` and `CircularParticlePainter` - `ParticlePainter` now extends `CircularParticlePainter` to eliminate code duplication

### Improved
- Enhanced `LeafParticlePainter` with more realistic leaf shape using cubic Bézier curves
- Added central vein and side veins to leaf particles for natural appearance
- Proportional vein thickness based on particle size

### Performance
- Optimized `shouldRepaint` in `CircularParticlePainter` and `SnowflakeParticlePainter` with deep comparison using hashCode, reducing unnecessary repaints

## 0.0.6

### Fixed
- Applied dart format to all library files for pub.dev compliance
- Updated example dependencies (flutter_lints to ^6.0.0)

## 0.0.5

### Added
- Frame rate control via `frameRateMs` parameter for performance tuning
- Comprehensive inline documentation for all public APIs
- Proper CHANGELOG documentation

### Fixed
- Particles now initialize with correct screen dimensions instead of hardcoded 1000px
- Removed duplicate `update()` calls in painters (~50% performance improvement)
- Particles properly adapt to `LayoutBuilder` constraints

### Changed
- Enhanced documentation with dartdoc comments throughout the codebase

### Performance
- Significant performance improvement by eliminating redundant particle updates per frame
- Particles now initialize efficiently with actual screen dimensions

## 0.0.4

### Changed
- Updated package version and metadata

## 0.0.3

### Changed
- Updated package dependencies in README

## 0.0.2

### Changed
- Updated homepage and repository URLs in pubspec.yaml

## 0.0.1

### Added
- Initial release
- Snowfall animation widget
- Support for circular and snowflake particle types
- Custom painter support for advanced rendering
- Custom widget support for particles
- Configurable particle properties: count, size, speed, color
