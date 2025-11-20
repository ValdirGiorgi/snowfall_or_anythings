# Changelog

All notable changes to this project will be documented in this file.

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
