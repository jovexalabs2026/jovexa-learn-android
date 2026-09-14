import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models.dart';

/// Loads all bundled learning content once at startup. Content is packaged as
/// JSON assets so the entire app works offline.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  List<String> categories = [];
  List<Course> courses = [];
  List<LearnPath> paths = [];
  List<String> referenceCategories = [];
  List<ReferenceEntry> referenceEntries = [];

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final coursesJson =
        jsonDecode(await rootBundle.loadString('assets/content/courses.json'))
            as Map<String, dynamic>;
    categories = (coursesJson['categories'] as List).cast<String>();
    courses = (coursesJson['courses'] as List)
        .map((c) => Course.fromJson(c as Map<String, dynamic>))
        .toList();

    final pathsJson =
        jsonDecode(await rootBundle.loadString('assets/content/paths.json'))
            as Map<String, dynamic>;
    paths = (pathsJson['paths'] as List)
        .map((p) => LearnPath.fromJson(p as Map<String, dynamic>))
        .toList();

    final refJson =
        jsonDecode(await rootBundle.loadString('assets/content/reference.json'))
            as Map<String, dynamic>;
    referenceCategories = (refJson['categories'] as List).cast<String>();
    referenceEntries = (refJson['entries'] as List)
        .map((e) => ReferenceEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  Course? course(String slug) {
    for (final c in courses) {
      if (c.slug == slug) return c;
    }
    return null;
  }

  (Course, Lesson, int)? lesson(String courseSlug, String lessonSlug) {
    final c = course(courseSlug);
    if (c == null) return null;
    for (var i = 0; i < c.lessons.length; i++) {
      if (c.lessons[i].slug == lessonSlug) return (c, c.lessons[i], i);
    }
    return null;
  }

  List<(String, List<Course>)> coursesByCategory() {
    return [
      for (final cat in categories)
        if (courses.any((c) => c.category == cat))
          (cat, courses.where((c) => c.category == cat).toList()),
    ];
  }

  int get totalLessons => courses.fold(0, (sum, c) => sum + c.lessons.length);
}
