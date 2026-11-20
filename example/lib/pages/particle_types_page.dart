import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class ParticleTypesPage extends StatefulWidget {
  const ParticleTypesPage({super.key});

  @override
  State<ParticleTypesPage> createState() => _ParticleTypesPageState();
}

class _ParticleTypesPageState extends State<ParticleTypesPage> {
  ParticleType _selectedType = ParticleType.snowflake;
  Color _selectedColor = Colors.white;
  double _particleSize = 12.0;

  final Map<ParticleType, String> _typeNames = {
    ParticleType.circular: 'Circular',
    ParticleType.snowflake: 'Snowflake',
    ParticleType.star: 'Star',
    ParticleType.heart: 'Heart',
    ParticleType.leaf: 'Leaf',
    ParticleType.raindrop: 'Raindrop',
  };

  final List<Color> _colors = [
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Particle Types Demo'),
        backgroundColor: Colors.black54,
      ),
      body: Stack(
        children: [
          // Particle animation
          SnowfallOrAnythings(
            numberOfParticles: 150,
            particleSize: _particleSize,
            particleSpeed: 1.5,
            particleType: _selectedType,
            particleColor: _selectedColor,
          ),
          // Controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Particle type selector
                  const Text(
                    'Particle Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children:
                        ParticleType.values.map((type) {
                          final isSelected = type == _selectedType;
                          return ChoiceChip(
                            label: Text(_typeNames[type]!),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedType = type);
                              }
                            },
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Size slider
                  Text(
                    'Particle Size: ${_particleSize.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _particleSize,
                    min: 4.0,
                    max: 30.0,
                    divisions: 26,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      setState(() => _particleSize = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Color selector
                  const Text(
                    'Particle Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children:
                        _colors.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isSelected ? Colors.white : Colors.grey,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: color.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
