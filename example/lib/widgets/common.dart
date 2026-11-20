import 'package:example/links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Highlighted card inviting people to read the blog article.
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFF3A2A12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.amber, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openLink(context, Links.article),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝  ARTICLE',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.amber,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How Snowfall or Anythings was built',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Time-based animation, painting thousands of particles '
                      'without rebuilding widgets, mixing shapes and emojis '
                      'with percentages, and keeping a published package '
                      'free of breaking changes.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: () => openLink(context, Links.article),
                icon: const Icon(Icons.menu_book),
                label: const Text('Read the article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `flutter pub add` command with a copy button.
class InstallCommand extends StatelessWidget {
  const InstallCommand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: SelectableText(
              Links.installCommand,
              style: TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(text: Links.installCommand),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// "Created by Valdir Giorgi" + project links.
class CreditsFooter extends StatelessWidget {
  const CreditsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Created by ', style: theme.textTheme.bodyMedium),
              TextButton(
                style: linkStyle,
                onPressed: () => openLink(context, Links.blog),
                child: const Text(
                  Links.author,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                style: linkStyle,
                onPressed: () => openLink(context, Links.article),
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('Article'),
              ),
              TextButton.icon(
                style: linkStyle,
                onPressed: () => openLink(context, Links.pubDev),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: const Text('pub.dev'),
              ),
              TextButton.icon(
                style: linkStyle,
                onPressed: () => openLink(context, Links.github),
                icon: const Icon(Icons.code, size: 18),
                label: const Text('GitHub'),
              ),
              TextButton.icon(
                style: linkStyle,
                onPressed: () => openLink(context, Links.issues),
                icon: const Icon(Icons.bug_report_outlined, size: 18),
                label: const Text('Issues'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'snowfall_or_anythings ${Links.packageVersion} · MIT License',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
