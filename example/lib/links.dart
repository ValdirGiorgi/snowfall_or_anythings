import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// All external links of the demo app in one place.
abstract final class Links {
  static const packageVersion = '0.0.9';
  static const author = 'Valdir Giorgi';

  static const liveDemo = 'https://snowfall.valdir.dev.br';
  static const blog = 'https://blog.valdir.dev.br';
  static const article =
      'https://blog.valdir.dev.br/snowfall-or-anythings-como-foi-construido';
  static const pubDev = 'https://pub.dev/packages/snowfall_or_anythings';
  static const github = 'https://github.com/ValdirGiorgi/snowfall_or_anythings';
  static const issues =
      'https://github.com/ValdirGiorgi/snowfall_or_anythings/issues';

  static const installCommand = 'flutter pub add snowfall_or_anythings';
}

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $url')));
  }
}
