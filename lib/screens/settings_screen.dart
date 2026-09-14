import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../progress_store.dart';
import '../settings_store.dart';
import '../widgets/code_block.dart';

/// App settings: appearance, font sizes, data reset, and about links.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all progress?'),
        content: const Text(
          'This removes lesson completion, quiz scores, bookmarks, and history from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ProgressStore.instance.clearAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All progress has been cleared.')),
    );
  }

  ListTile _linkTile(IconData icon, String title, String url) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
    onTap: () => _openLink(url),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SettingsStore.instance,
          builder: (context, _) {
            final settings = SettingsStore.instance;
            final scheme = Theme.of(context).colorScheme;
            const fontScales = <double>[0.9, 1.0, 1.1, 1.2];
            final scale = fontScales.contains(settings.fontScale)
                ? settings.fontScale
                : 1.0;
            final double codeSize = settings.codeFontSize
                .clamp(11.0, 17.0)
                .toDouble();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader('Appearance'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) =>
                            settings.setThemeMode(selection.first),
                      ),
                    ),
                  ),
                ),
                const _SectionHeader('Reading font size'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<double>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 0.9, label: Text('Small')),
                          ButtonSegment(value: 1.0, label: Text('Default')),
                          ButtonSegment(value: 1.1, label: Text('Large')),
                          ButtonSegment(value: 1.2, label: Text('Larger')),
                        ],
                        selected: {scale},
                        onSelectionChanged: (selection) =>
                            settings.setFontScale(selection.first),
                      ),
                    ),
                  ),
                ),
                const _SectionHeader('Code font size'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: codeSize,
                                min: 11,
                                max: 17,
                                divisions: 6,
                                label: '${codeSize.round()}',
                                onChanged: (value) =>
                                    settings.setCodeFontSize(value),
                              ),
                            ),
                            Text('${codeSize.round()} px'),
                          ],
                        ),
                        const CodeBlock(
                          code: 'let total = price * quantity;',
                          language: 'js',
                        ),
                      ],
                    ),
                  ),
                ),
                const _SectionHeader('Data'),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                    ),
                    title: Text(
                      'Clear all progress',
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Removes completion, quiz scores, bookmarks, and history.',
                    ),
                    onTap: () => _confirmClear(context),
                  ),
                ),
                const _SectionHeader('About'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _linkTile(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',
                        'https://jovexalabs.com/privacy',
                      ),
                      _linkTile(
                        Icons.description_outlined,
                        'Terms of Use',
                        'https://jovexalabs.com/terms',
                      ),
                      _linkTile(
                        Icons.language_rounded,
                        'Website',
                        'https://jovexalabs.com',
                      ),
                      _linkTile(
                        Icons.code_rounded,
                        'Source code on GitHub',
                        'https://github.com/jovexalabs2026/jovexa-learn-android',
                      ),
                      const ListTile(
                        leading: Icon(Icons.school_outlined),
                        title: Text('Jovexa Learn 1.0.0'),
                        subtitle: Text(
                          'by Jovexa Labs. Free coding education for everyone.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
