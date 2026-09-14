import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jovexa_learn/models.dart';

/// Validates the bundled learning content so a broken export can never ship.
void main() {
  late List<Course> courses;
  late List<LearnPath> paths;
  late List<ReferenceEntry> entries;

  setUpAll(() {
    final coursesJson =
        jsonDecode(File('assets/content/courses.json').readAsStringSync())
            as Map<String, dynamic>;
    courses = (coursesJson['courses'] as List)
        .map((c) => Course.fromJson(c as Map<String, dynamic>))
        .toList();
    final pathsJson =
        jsonDecode(File('assets/content/paths.json').readAsStringSync())
            as Map<String, dynamic>;
    paths = (pathsJson['paths'] as List)
        .map((p) => LearnPath.fromJson(p as Map<String, dynamic>))
        .toList();
    final refJson =
        jsonDecode(File('assets/content/reference.json').readAsStringSync())
            as Map<String, dynamic>;
    entries = (refJson['entries'] as List)
        .map((e) => ReferenceEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  test('ships 7 courses with 61 lessons', () {
    expect(courses.length, 7);
    expect(courses.fold<int>(0, (s, c) => s + c.lessons.length), 61);
  });

  test('course and lesson slugs are unique', () {
    final courseSlugs = courses.map((c) => c.slug).toSet();
    expect(courseSlugs.length, courses.length);
    for (final c in courses) {
      final lessonSlugs = c.lessons.map((l) => l.slug).toSet();
      expect(
        lessonSlugs.length,
        c.lessons.length,
        reason: 'dupes in ${c.slug}',
      );
    }
  });

  test('every lesson has an objective, sections, and valid exercise', () {
    for (final c in courses) {
      for (final l in c.lessons) {
        expect(l.title, isNotEmpty);
        expect(l.objective, isNotEmpty, reason: '${c.slug}/${l.slug}');
        expect(l.sections, isNotEmpty, reason: '${c.slug}/${l.slug}');
        final ex = l.exercise;
        if (ex != null) {
          expect(ex.options.length, greaterThanOrEqualTo(2));
          expect(ex.answer, inInclusiveRange(0, ex.options.length - 1));
          expect(ex.explanation, isNotEmpty);
        }
      }
    }
  });

  test('every course quiz question has a valid answer index', () {
    for (final c in courses) {
      expect(c.quiz, isNotEmpty, reason: '${c.slug} has no quiz');
      for (final q in c.quiz) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1));
        expect(q.explanation, isNotEmpty);
      }
    }
  });

  test('path steps only reference courses and lessons that exist', () {
    final bySlug = {for (final c in courses) c.slug: c};
    for (final p in paths) {
      expect(p.steps, isNotEmpty);
      for (final s in p.steps) {
        if (s.course != null) {
          final c = bySlug[s.course];
          expect(c, isNotNull, reason: '${p.slug}: unknown course ${s.course}');
          if (s.lesson != null) {
            expect(
              c!.lessons.any((l) => l.slug == s.lesson),
              isTrue,
              reason: '${p.slug}: unknown lesson ${s.course}/${s.lesson}',
            );
          }
        }
      }
    }
  });

  test('reference entries are unique and complete', () {
    expect(entries.length, 77);
    expect(entries.map((e) => e.id).toSet().length, entries.length);
    for (final e in entries) {
      expect(e.name, isNotEmpty);
      expect(e.description, isNotEmpty);
      expect(e.example, isNotEmpty);
    }
  });

  test('content contains no em dashes', () {
    for (final file in ['courses.json', 'paths.json', 'reference.json']) {
      final raw = File('assets/content/$file').readAsStringSync();
      expect(
        raw.contains('\u2014'),
        isFalse,
        reason: '$file contains an em dash',
      );
    }
  });
}
