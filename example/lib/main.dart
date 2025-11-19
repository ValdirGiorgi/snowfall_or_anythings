import 'package:example/pages/custom_paint_page.dart';
import 'package:example/pages/frame_rate_page.dart';
import 'package:example/pages/snow_page.dart';
import 'package:example/pages/widget_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Particle Demo',
      theme: ThemeData.dark(),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Particle Effects Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SnowPage(),
                  ),
                );
              },
              child: const Text('Snowfall Demo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomPaintpage(),
                  ),
                );
              },
              child: const Text('CustomPainter Demo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WidgetParticlePage(),
                  ),
                );
              },
              child: const Text('Widget Particle Demo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FrameRatePage(),
                  ),
                );
              },
              child: const Text('Frame Rate Control Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPaintDemo {
  const CustomPaintDemo();
}
