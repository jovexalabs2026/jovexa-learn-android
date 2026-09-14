import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../progress_store.dart';
import '../theme.dart';

/// Home tab: streak, continue learning, course shortcuts, paths, practice,
/// recent lessons, and bookmarks.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<(Course, Lesson)> _resolveKeys(List<String> keys) {
    final repo = ContentRepository.instance;
    final out = <(Course, Lesson)>[];
    for (final key in keys) {
      final parts = key.split('/');
      if (parts.length != 2) continue;
      final hit = repo.lesson(parts[0], parts[1]);
      if (hit != null) out.add((hit.$1, hit.$2));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jovexa Learn'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: ProgressStore.instance,
        builder: (context, _) {
          final repo = ContentRepository.instance;
          final store = ProgressStore.instance;
          final recent = _resolveKeys(store.recent);
          final marked = _resolveKeys(store.bookmarks);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HomeHeader(streak: store.streak),
              const SizedBox(height: 24),
              const _SectionTitle('Continue Learning'),
              if (recent.isEmpty)
                _ActionCard(
                  icon: Icons.rocket_launch_rounded,
                  title: 'Start your first course',
                  description:
                      'Pick a topic and begin learning in minutes. Progress is saved on this device.',
                  buttonLabel: 'Browse courses',
                  onPressed: () => context.go('/courses'),
                )
              else
                _ContinueCard(course: recent.first.$1, lesson: recent.first.$2),
              if (repo.courses.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle('Popular Courses'),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: repo.courses.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        _CourseMiniCard(course: repo.courses[i]),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _SectionTitle('Learning Paths'),
              _ActionCard(
                icon: Icons.route_rounded,
                title: 'Guided paths',
                description:
                    'Follow a curated sequence of courses and lessons toward a clear goal.',
                buttonLabel: 'Explore paths',
                onPressed: () => context.push('/paths'),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Daily Practice'),
              _ActionCard(
                icon: Icons.bolt_rounded,
                title: 'Sharpen your skills',
                description:
                    'A quick round of mixed questions drawn from the courses you study.',
                buttonLabel: 'Start practice',
                onPressed: () => context.push('/practice'),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle('Recently Viewed'),
                Card(
                  child: Column(
                    children: [
                      for (final (course, lesson) in recent.take(5))
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
              if (marked.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: _SectionTitle(
                        'Bookmarks',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/my'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Card(
                  child: Column(
                    children: [
                      for (final (course, lesson) in marked.take(3))
                        ListTile(
                          leading: Icon(
                            Icons.bookmark_rounded,
                            color: Theme.of(context).colorScheme.primary,
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
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final int streak;

  const _HomeHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JovexaTheme.brandBlue.withValues(alpha: 0.22),
            JovexaTheme.brandCyan.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn code. Build skills. Create more.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          if (streak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                    color: Colors.deepOrangeAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$streak day streak',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const _SectionTitle(
    this.text, {
    this.padding = const EdgeInsets.only(bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Course course;
  final Lesson lesson;

  const _ContinueCard({required this.course, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    context.go('/courses/${course.slug}/lesson/${lesson.slug}'),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseMiniCard extends StatelessWidget {
  final Course course;

  const _CourseMiniCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go('/courses/${course.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${course.lessons.length} lessons',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course.level,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(icon, size: 22, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
