import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';

/// Personal dashboard: streak, totals, resume card, per-course progress,
/// recent lessons, and saved bookmarks.
class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  (Course, Lesson)? _resolve(String key) {
    final parts = key.split('/');
    if (parts.length != 2) return null;
    final hit = ContentRepository.instance.lesson(parts[0], parts[1]);
    if (hit == null) return null;
    return (hit.$1, hit.$2);
  }

  (Course, Lesson)? _firstResume(ProgressStore store) {
    for (final key in store.recent) {
      final hit = _resolve(key);
      if (hit != null) return hit;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ProgressStore.instance,
          builder: (context, _) {
            final store = ProgressStore.instance;
            final repo = ContentRepository.instance;
            final textTheme = Theme.of(context).textTheme;
            final scheme = Theme.of(context).colorScheme;

            final resume = _firstResume(store);

            final progressCourses = [
              for (final course in repo.courses)
                if (store.completedCount(course.slug) > 0 ||
                    store.quizScore(course.slug) != null)
                  course,
            ];

            final recentTiles = <(Course, Lesson)>[];
            for (final key in store.recent) {
              final hit = _resolve(key);
              if (hit != null) recentTiles.add(hit);
              if (recentTiles.length == 8) break;
            }

            final bookmarkTiles = <(Course, Lesson)>[];
            for (final key in store.bookmarks) {
              final hit = _resolve(key);
              if (hit != null) bookmarkTiles.add(hit);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: store.streak == 1
                            ? '1 day'
                            : '${store.streak} days',
                        label: 'Streak',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book_rounded,
                        value:
                            '${store.totalCompleted} of ${repo.totalLessons}',
                        label: 'Lessons',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bookmark_rounded,
                        value: '${store.bookmarks.length}',
                        label: 'Bookmarks',
                      ),
                    ),
                  ],
                ),
                if (resume != null) ...[
                  const _SectionHeader('Resume'),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            resume.$1.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resume.$2.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  resume.$1.title,
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () => context.go(
                              '/courses/${resume.$1.slug}/lesson/${resume.$2.slug}',
                            ),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const _SectionHeader('Course Progress'),
                if (progressCourses.isEmpty)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Nothing here yet. Pick a course and finish your first lesson to see progress.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.go('/courses'),
                            child: const Text('Browse courses'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          for (final course in progressCourses)
                            _CourseProgressRow(course: course, store: store),
                        ],
                      ),
                    ),
                  ),
                if (recentTiles.isNotEmpty) ...[
                  const _SectionHeader('Recently Viewed'),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (course, lesson) in recentTiles)
                          ListTile(
                            leading: Text(
                              course.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              lesson.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.go(
                              '/courses/${course.slug}/lesson/${lesson.slug}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const _SectionHeader('Bookmarks'),
                if (bookmarkTiles.isEmpty)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No bookmarks yet. Save any lesson with the bookmark icon and it will show up here.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (course, lesson) in bookmarkTiles)
                          ListTile(
                            leading: Text(
                              course.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              lesson.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove bookmark',
                              icon: Icon(
                                Icons.bookmark_rounded,
                                color: scheme.primary,
                              ),
                              onPressed: () => store.toggleBookmark(
                                course.slug,
                                lesson.slug,
                              ),
                            ),
                            onTap: () => context.go(
                              '/courses/${course.slug}/lesson/${lesson.slug}',
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: textTheme.bodySmall, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _CourseProgressRow extends StatelessWidget {
  final Course course;
  final ProgressStore store;

  const _CourseProgressRow({required this.course, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final done = store.completedCount(course.slug);
    final total = course.lessons.length;
    final score = store.quizScore(course.slug);
    final quizTotal = course.quiz.length;
    final quizStrong =
        score != null && quizTotal > 0 && score * 10 >= quizTotal * 7;
    final quizColor = quizStrong ? Colors.green : scheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (score != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: quizColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Quiz: $score of $quizTotal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: quizColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done of $total lessons complete',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
