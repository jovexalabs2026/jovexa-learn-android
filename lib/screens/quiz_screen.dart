import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';

/// Course quiz: one question at a time with instant feedback and a final
/// score summary. The best score is saved to local progress.
class QuizScreen extends StatefulWidget {
  final String courseSlug;

  const QuizScreen({super.key, required this.courseSlug});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _score = 0;
  bool _answered = false;
  int? _selected;
  bool _finished = false;

  void _check(ExerciseQuestion question) {
    if (_selected == null) return;
    setState(() {
      _answered = true;
      if (_selected == question.answer) _score++;
    });
  }

  void _next(int total) {
    if (_index + 1 >= total) {
      // Save once, at the moment the quiz finishes.
      ProgressStore.instance.setQuizScore(widget.courseSlug, _score);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _answered = false;
        _selected = null;
      });
    }
  }

  void _retry() {
    setState(() {
      _index = 0;
      _score = 0;
      _answered = false;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = ContentRepository.instance.course(widget.courseSlug);
    if (course == null || course.quiz.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Quiz')),
        body: const Center(child: Text('Quiz not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Course Quiz')),
      body: _finished
          ? _buildResults(context, course)
          : _buildQuestion(context, course),
    );
  }

  Widget _buildQuestion(BuildContext context, Course course) {
    final scheme = Theme.of(context).colorScheme;
    final total = course.quiz.length;
    final ExerciseQuestion q = course.quiz[_index];
    final correct = _selected == q.answer;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (_index + 1) / total,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Question ${_index + 1} of $total',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          q.question,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _QuizOption(
              label: q.options[i],
              selected: _selected == i,
              answered: _answered,
              isCorrectAnswer: i == q.answer,
              onTap: _answered ? null : () => setState(() => _selected = i),
            ),
          ),
        const SizedBox(height: 8),
        if (!_answered)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected == null ? null : () => _check(q),
              child: const Text('Check answer'),
            ),
          )
        else ...[
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 20,
                color: correct ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct
                      ? 'Correct.'
                      : 'Incorrect. The right answer is highlighted.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _next(total),
              child: Text(
                _index + 1 >= total ? 'See results' : 'Next question',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResults(BuildContext context, Course course) {
    final total = course.quiz.length;
    final percent = (_score / total * 100).round();
    final passed = _score / total >= 0.7;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You scored $_score of $total',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: (passed ? Colors.green : Colors.amber).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    passed
                        ? Icons.check_circle_rounded
                        : Icons.trending_up_rounded,
                    size: 18,
                    color: passed ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    passed ? 'Passed' : 'Keep practicing',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: passed ? Colors.green : Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retry,
                    child: const Text('Retry quiz'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        context.go('/courses/${widget.courseSlug}'),
                    child: const Text('Back to course'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool answered;
  final bool isCorrectAnswer;
  final VoidCallback? onTap;

  const _QuizOption({
    required this.label,
    required this.selected,
    required this.answered,
    required this.isCorrectAnswer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outlineVariant;
    Color? fill;
    if (answered && isCorrectAnswer) {
      border = Colors.green;
      fill = Colors.green.withValues(alpha: 0.12);
    } else if (answered && selected) {
      border = Colors.redAccent;
      fill = Colors.redAccent.withValues(alpha: 0.12);
    } else if (!answered && selected) {
      border = scheme.primary;
      fill = scheme.primary.withValues(alpha: 0.10);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
