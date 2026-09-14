import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings_store.dart';
import '../theme.dart';

/// Displays a code example in a monospace block with a language label and a
/// copy button. Font size follows the code font size setting.
class CodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const CodeBlock({super.key, required this.code, this.language});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: SettingsStore.instance,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? JovexaTheme.codeBg : JovexaTheme.codeBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
                child: Row(
                  children: [
                    Text(
                      (language ?? 'code').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: JovexaTheme.brandCyan.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Copy code',
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      color: Colors.white70,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                      },
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: SettingsStore.instance.codeFontSize,
                    height: 1.5,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
