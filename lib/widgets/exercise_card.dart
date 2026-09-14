import 'package:flutter/material.dart';

import '../models.dart';

/// Interactive multiple choice exercise with instant feedback, explanation,
/// and a retry option. Used in lessons, quizzes, and daily practice.
class ExerciseCard extends StatefulWidget {
  final ExerciseQuestion question;
  final String? title;
  final ValueChanged<bool>? onAnswered;

  const ExerciseCard({
    super.key,
    required this.question,
    this.title,
    this.onAnswered,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  int? _selected;
  bool _checked = false;

  bool get _correct => _selected == widget.question.answer;

  void _reset() => setState(() {
    _selected = null;
    _checked = false;
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = widget.question;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(q.question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionTile(
                  label: q.options[i],
                  selected: _selected == i,
                  state: !_checked
                      ? _OptionState.idle
                      : i == q.answer
                      ? _OptionState.correct
                      : _selected == i
                      ? _OptionState.wrong
                      : _OptionState.idle,
                  onTap: _checked ? null : () => setState(() => _selected = i),
                ),
              ),
            const SizedBox(height: 4),
            if (!_checked)
              FilledButton(
                onPressed: _selected == null
                    ? null
                    : () {
                        setState(() => _checked = true);
                        widget.onAnswered?.call(_correct);
                      },
                child: const Text('Check answer'),
              )
            else ...[
              Row(
                children: [
                  Icon(
                    _correct
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _correct
                        ? Colors.greenAccent.shade400
                        : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _correct
                        ? 'Correct. Nice work.'
                        : 'Not quite. Review the explanation.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q.explanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (!_correct)
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Try again'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outlineVariant;
    Color? fill;
    if (state == _OptionState.correct) {
      border = Colors.green;
      fill = Colors.green.withValues(alpha: 0.12);
    } else if (state == _OptionState.wrong) {
      border = Colors.redAccent;
      fill = Colors.redAccent.withValues(alpha: 0.12);
    } else if (selected) {
      border = scheme.primary;
      fill = scheme.primary.withValues(alpha: 0.10);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Text(label),
      ),
    );
  }
}
