import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';
import '../widgets/code_block.dart';
import '../widgets/exercise_card.dart';

/// Lesson reader: objective, sections with code, common mistakes, practice
/// exercise, completion toggle, and previous/next navigation.
class LessonScreen extends StatefulWidget {
  final String courseSlug;
  final String lessonSlug;

  const LessonScreen({
    super.key,
    required this.courseSlug,
    required this.lessonSlug,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ProgressStore.instance.recordVisit(widget.courseSlug, widget.lessonSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hit = ContentRepository.instance.lesson(
      widget.courseSlug,
      widget.lessonSlug,
    );
    if (hit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found')),
      );
    }
    final (course, lesson, index) = hit;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, overflow: TextOverflow.ellipsis),
        actions: [
          ListenableBuilder(
            listenable: ProgressStore.instance,
            builder: (context, _) {
              final marked = ProgressStore.instance.isBookmarked(
                widget.courseSlug,
                widget.lessonSlug,
              );
              return IconButton(
                tooltip: marked ? 'Remove bookmark' : 'Bookmark lesson',
                icon: Icon(
                  marked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                onPressed: () => ProgressStore.instance.toggleBookmark(
                  widget.courseSlug,
                  widget.lessonSlug,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Lesson ${index + 1} of ${course.lessons.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (lesson.objective.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              color: scheme.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_rounded, size: 20, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Objective',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.objective,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          for (final LessonSection section in lesson.sections) ...[
            const SizedBox(height: 20),
            Text(
              section.heading,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              section.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (section.code != null)
              CodeBlock(code: section.code!, language: section.language),
          ],
          if (lesson.mistakes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              color: Colors.amber.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Common Mistakes',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final mistake in lesson.mistakes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(
                              child: Text(
                                mistake,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (lesson.exercise != null) ...[
            const SizedBox(height: 20),
            ExerciseCard(
              question: lesson.exercise!,
              title: 'Practice Exercise',
            ),
          ],
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: ProgressStore.instance,
            builder: (context, _) {
              final done = ProgressStore.instance.isLessonComplete(
                widget.courseSlug,
                widget.lessonSlug,
              );
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ProgressStore.instance.toggleLessonComplete(
                    widget.courseSlug,
                    widget.lessonSlug,
                  ),
                  icon: Icon(
                    done ? Icons.check_circle_rounded : Icons.check_rounded,
                  ),
                  label: Text(done ? 'Completed' : 'Mark as complete'),
                  style: done
                      ? FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _PrevNextRow(course: course, index: index),
        ],
      ),
    );
  }
}

class _PrevNextRow extends StatelessWidget {
  final Course course;
  final int index;

  const _PrevNextRow({required this.course, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasPrev = index > 0;
    final hasNext = index < course.lessons.length - 1;
    final String nextLabel;
    final VoidCallback? nextAction;
    if (hasNext) {
      nextLabel = 'Next';
      nextAction = () => context.go(
        '/courses/${course.slug}/lesson/${course.lessons[index + 1].slug}',
      );
    } else if (course.quiz.isNotEmpty) {
      nextLabel = 'Course quiz';
      nextAction = () => context.go('/courses/${course.slug}/quiz');
    } else {
      nextLabel = 'Next';
      nextAction = null;
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasPrev
                ? () => context.go(
                    '/courses/${course.slug}/lesson/${course.lessons[index - 1].slug}',
                  )
                : null,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: nextAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            iconAlignment: IconAlignment.end,
            label: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
