import 'package:example/particles/my_custom_particle.dart';
import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

enum _RenderMode { shape, widget, customPainter }

/// Every parameter of [SnowfallOrAnythings], changed live without a Key.
class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  _RenderMode _mode = _RenderMode.shape;
  ParticleType _type = ParticleType.snowflake;
  Color _color = Colors.white;
  double _count = 150;
  double _size = 6;
  double _speed = 1;
  bool _limitFps = false;
  double _maxFps = 30;

  static const _colors = [
    Colors.white,
    Colors.lightBlueAccent,
    Colors.amber,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.deepOrangeAccent,
    Colors.purpleAccent,
  ];

  String get _code {
    final lines = <String>[
      'numberOfParticles: ${_count.round()},',
      'particleSize: ${_size.toStringAsFixed(1)},',
      'particleSpeed: ${_speed.toStringAsFixed(1)},',
      if (_mode != _RenderMode.widget)
        'particleColor: Color(0x${_color.toARGB32().toRadixString(16)}),',
      if (_mode == _RenderMode.shape) 'particleType: $_type,',
      if (_mode == _RenderMode.widget) "particleWidget: Text('❄️'),",
      if (_mode == _RenderMode.customPainter)
        'customPainter: ({required particles}) =>\n'
            '    CustomParticlePainter(particles),',
      if (_limitFps) 'maxFps: ${_maxFps.round()},',
    ];
    return 'SnowfallOrAnythings(\n${lines.map((l) => '  $l').join('\n')}\n)';
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 800;
    final animation = Container(
      color: const Color(0xFF0B1D3A),
      child: SnowfallOrAnythings(
        numberOfParticles: _count.round(),
        particleSize: _size,
        particleSpeed: _speed,
        particleColor: _color,
        particleType: _type,
        maxFps: _limitFps ? _maxFps : null,
        particleWidget:
            _mode == _RenderMode.widget
                ? const FittedBox(child: Text('❄️'))
                : null,
        customPainter:
            _mode == _RenderMode.customPainter
                ? ({required particles}) => CustomParticlePainter(particles)
                : null,
      ),
    );
    final controls = _buildControls(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Playground')),
      body:
          wide
              ? Row(
                children: [
                  Expanded(child: animation),
                  SizedBox(width: 360, child: controls),
                ],
              )
              : Column(
                children: [
                  Expanded(child: animation),
                  SizedBox(height: 320, child: controls),
                ],
              ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<_RenderMode>(
          segments: const [
            ButtonSegment(value: _RenderMode.shape, label: Text('Shape')),
            ButtonSegment(value: _RenderMode.widget, label: Text('Widget')),
            ButtonSegment(
              value: _RenderMode.customPainter,
              label: Text('Painter'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        if (_mode == _RenderMode.shape)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in ParticleType.values)
                ChoiceChip(
                  label: Text(type.name),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
        if (_mode != _RenderMode.widget) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final color in _colors)
                GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: color,
                    child:
                        _color == color
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            )
                            : null,
                  ),
                ),
            ],
          ),
        ],
        _slider('Particles', _count, 0, 600, (v) => _count = v, digits: 0),
        _slider('Size', _size, 1, 40, (v) => _size = v),
        _slider('Speed', _speed, 0, 8, (v) => _speed = v),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Limit FPS (maxFps)'),
          value: _limitFps,
          onChanged: (v) => setState(() => _limitFps = v),
        ),
        if (_limitFps)
          _slider('maxFps', _maxFps, 5, 120, (v) => _maxFps = v, digits: 0),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            _code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged, {
    int digits = 1,
  }) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toStringAsFixed(digits), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
