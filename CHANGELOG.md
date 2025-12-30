# Changelog

All notable changes to this project will be documented in this file.

## 0.0.8

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

### Improved
- Enhanced `LeafParticlePainter` with more realistic leaf shape using cubic Bézier curves
- Added central vein and side veins to leaf particles for natural appearance
- Proportional vein thickness based on particle size

## 0.0.7

### Performance
- Optimized `shouldRepaint` in `CircularParticlePainter` and `SnowflakeParticlePainter` with deep comparison using hashCode, reducing unnecessary repaints

### Changed
- Added `hashCode` and `==` operators to `Particle` class for proper comparison
- Unified `ParticlePainter` and `CircularParticlePainter` - `ParticlePainter` now extends `CircularParticlePainter` to eliminate code duplication

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
