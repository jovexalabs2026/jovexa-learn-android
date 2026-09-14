import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';

/// Course detail: overview, progress, quiz entry, and the lesson list.
class CourseScreen extends StatelessWidget {
  final String courseSlug;

  const CourseScreen({super.key, required this.courseSlug});

  @override
  Widget build(BuildContext context) {
    final Course? course = ContentRepository.instance.course(courseSlug);
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, overflow: TextOverflow.ellipsis),
      ),
      body: ListenableBuilder(
        listenable: ProgressStore.instance,
        builder: (context, _) {
          final scheme = Theme.of(context).colorScheme;
          final store = ProgressStore.instance;
          final total = course.lessons.length;
          final completedRaw = store.completedCount(course.slug);
          final completed = completedRaw > total ? total : completedRaw;
          final firstIncomplete = course.lessons.indexWhere(
            (l) => !store.isLessonComplete(course.slug, l.slug),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      course.icon,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.tagline,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(label: course.level),
                  _InfoChip(label: '~${course.estimatedHours}h'),
                  _InfoChip(label: '$total lessons'),
                ],
              ),
              const SizedBox(height: 16),
              _ProgressCard(
                course: course,
                completed: completed,
                total: total,
                firstIncomplete: firstIncomplete,
              ),
              if (course.quiz.isNotEmpty) ...[
                const SizedBox(height: 12),
                _QuizCard(course: course),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Lessons',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < course.lessons.length; i++)
                      _LessonTile(
                        course: course,
                        index: i,
                        isCurrent: i == firstIncomplete,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Course course;
  final int completed;
  final int total;
  final int firstIncomplete;

  const _ProgressCard({
    required this.course,
    required this.completed,
    required this.total,
    required this.firstIncomplete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final String buttonLabel;
    final Lesson? target;
    if (total == 0) {
      buttonLabel = '';
      target = null;
    } else if (completed == 0) {
      buttonLabel = 'Start course';
      target = course.lessons.first;
    } else if (firstIncomplete == -1) {
      buttonLabel = 'Review course';
      target = course.lessons.first;
    } else {
      buttonLabel = 'Continue';
      target = course.lessons[firstIncomplete];
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$completed of $total lessons completed',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (target != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(
                    '/courses/${course.slug}/lesson/${target!.slug}',
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Course course;

  const _QuizCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final best = ProgressStore.instance.quizScore(course.slug);
    final passed = best != null && best / course.quiz.length >= 0.7;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Quiz',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${course.quiz.length} questions. Score 70% or higher to pass.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (best != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Best score: $best of ${course.quiz.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (passed ? Colors.green : Colors.amber).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      passed ? 'Passed' : 'Not passed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: passed ? Colors.green : Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => context.go('/courses/${course.slug}/quiz'),
                child: Text(best == null ? 'Take quiz' : 'Retake quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Course course;
  final int index;
  final bool isCurrent;

  const _LessonTile({
    required this.course,
    required this.index,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lesson = course.lessons[index];
    final done = ProgressStore.instance.isLessonComplete(
      course.slug,
      lesson.slug,
    );
    final IconData icon;
    final Color color;
    if (done) {
      icon = Icons.check_circle_rounded;
      color = Colors.green;
    } else if (isCurrent) {
      icon = Icons.play_circle_rounded;
      color = scheme.primary;
    } else {
      icon = Icons.radio_button_unchecked_rounded;
      color = scheme.outline;
    }
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        '${index + 1}. ${lesson.title}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.go('/courses/${course.slug}/lesson/${lesson.slug}'),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
