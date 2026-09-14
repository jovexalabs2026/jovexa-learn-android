import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';

/// Guided learning paths built from ordered course and lesson steps.
class PathsScreen extends StatelessWidget {
  const PathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Paths')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ProgressStore.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Guided routes that take you from first steps to real skills.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              for (final path in ContentRepository.instance.paths)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PathCard(path: path),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final LearnPath path;

  const _PathCard({required this.path});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Text(path.icon, style: const TextStyle(fontSize: 26)),
        title: Text(
          path.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          path.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          for (var i = 0; i < path.steps.length; i++)
            _PathStepTile(index: i, step: path.steps[i]),
        ],
      ),
    );
  }
}

class _PathStepTile extends StatelessWidget {
  final int index;
  final PathStep step;

  const _PathStepTile({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final courseSlug = step.course;
    final lessonSlug = step.lesson;
    final tappable = courseSlug != null;
    final complete =
        courseSlug != null &&
        lessonSlug != null &&
        ProgressStore.instance.isLessonComplete(courseSlug, lessonSlug);
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: complete
            ? Colors.green.withValues(alpha: 0.18)
            : scheme.primary.withValues(alpha: 0.12),
        child: complete
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.green)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
      ),
      title: Text(step.title),
      subtitle: step.note == null
          ? null
          : Text(step.note!, style: Theme.of(context).textTheme.bodySmall),
      trailing: tappable ? const Icon(Icons.chevron_right_rounded) : null,
      onTap: !tappable
          ? null
          : () {
              if (lessonSlug != null) {
                context.go('/courses/$courseSlug/lesson/$lessonSlug');
              } else {
                context.go('/courses/$courseSlug');
              }
            },
    );
  }
}
