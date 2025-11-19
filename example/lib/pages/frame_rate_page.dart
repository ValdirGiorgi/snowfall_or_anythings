import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class FrameRatePage extends StatefulWidget {
  const FrameRatePage({super.key});

  @override
  State<FrameRatePage> createState() => _FrameRatePageState();
}

class _FrameRatePageState extends State<FrameRatePage> {
  double _frameRateMs = 16.0; // Default 60 FPS

  int get _currentFPS => (1000 / _frameRateMs).round();

  String get _performanceLabel {
    if (_frameRateMs <= 10) return 'Ultra High';
    if (_frameRateMs <= 16) return 'High';
    if (_frameRateMs <= 33) return 'Medium';
    return 'Low';
  }

  Color get _performanceColor {
    if (_frameRateMs <= 10) return Colors.purple;
    if (_frameRateMs <= 16) return Colors.green;
    if (_frameRateMs <= 33) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frame Rate Control Demo'),
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Frame Rate:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _performanceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_currentFPS FPS',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _performanceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('120 FPS'),
                    Expanded(
                      child: Slider(
                        value: _frameRateMs,
                        min: 8,
                        max: 100,
                        divisions: 92,
                        label: '$_currentFPS FPS (${_frameRateMs.round()}ms)',
                        onChanged: (value) {
                          setState(() {
                            _frameRateMs = value;
                          });
                        },
                      ),
                    ),
                    const Text('10 FPS'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'frameRateMs: ${_frameRateMs.round()}ms',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Adjust the slider to change animation frame rate in real-time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Animation Area
          Expanded(
            child: SnowfallOrAnythings(
              key: ValueKey(_frameRateMs.round()),
              numberOfParticles: 150,
              particleSize: 4.0,
              particleSpeed: 1.0,
              particleType: ParticleType.snowflake,
              frameRateMs: _frameRateMs.round(),
            ),
          ),
        ],
      ),
    );
  }
}
