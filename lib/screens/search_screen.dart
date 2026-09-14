import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content_repository.dart';
import '../models.dart';
import '../widgets/code_block.dart';

/// Type-ahead search across courses, lessons, and the reference library.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showReferenceSheet(ReferenceEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(entry.description, style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                CodeBlock(code: entry.example),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final repo = ContentRepository.instance;
    final textTheme = Theme.of(context).textTheme;

    final courseHits = q.isEmpty
        ? const <Course>[]
        : repo.courses
              .where(
                (c) =>
                    c.title.toLowerCase().contains(q) ||
                    c.tagline.toLowerCase().contains(q),
              )
              .take(8)
              .toList();

    final lessonHits = <(Course, Lesson)>[];
    if (q.isNotEmpty) {
      outer:
      for (final course in repo.courses) {
        for (final lesson in course.lessons) {
          if (lesson.title.toLowerCase().contains(q) ||
              lesson.objective.toLowerCase().contains(q)) {
            lessonHits.add((course, lesson));
            if (lessonHits.length == 8) break outer;
          }
        }
      }
    }

    final refHits = q.isEmpty
        ? const <ReferenceEntry>[]
        : repo.referenceEntries
              .where(
                (e) =>
                    e.name.toLowerCase().contains(q) ||
                    e.description.toLowerCase().contains(q),
              )
              .take(8)
              .toList();

    Widget body;
    if (q.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Type to search all learning content.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
      );
    } else if (courseHits.isEmpty && lessonHits.isEmpty && refHits.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No results for that term.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
        children: [
          if (courseHits.isNotEmpty) ...[
            const _GroupHeader('Courses'),
            for (final course in courseHits)
              ListTile(
                leading: Text(
                  course.icon,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  course.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.go('/courses/${course.slug}'),
              ),
          ],
          if (lessonHits.isNotEmpty) ...[
            const _GroupHeader('Lessons'),
            for (final (course, lesson) in lessonHits)
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
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
                onTap: () =>
                    context.go('/courses/${course.slug}/lesson/${lesson.slug}'),
              ),
          ],
          if (refHits.isNotEmpty) ...[
            const _GroupHeader('Reference'),
            for (final entry in refHits)
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  entry.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showReferenceSheet(entry),
              ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search courses, lessons, and reference',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;

  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
