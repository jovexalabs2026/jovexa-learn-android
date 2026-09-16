import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jovexa_learn/content_repository.dart';
import 'package:jovexa_learn/main.dart';
import 'package:jovexa_learn/progress_store.dart';
import 'package:jovexa_learn/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the real app at Pixel-5 resolution to produce Play Store phone
/// screenshots:  flutter test test/store_screenshots_test.dart
///
/// System fonts must be loaded explicitly, otherwise the test harness paints
/// every glyph as an empty box.
const _out = 'store/screens';
const _logical = Size(393, 851);
const _dpr = 2.75; // -> 1080 x 2340

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  var any = false;
  for (final p in paths) {
    final file = File(p);
    if (!file.existsSync()) continue;
    any = true;
    loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  }
  if (any) await loader.load();
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  final key = GlobalKey();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont('Roboto', [
      'C:/Windows/Fonts/segoeui.ttf',
      'C:/Windows/Fonts/segoeuib.ttf',
      'C:/Windows/Fonts/seguiemj.ttf',
      'C:/Windows/Fonts/seguisym.ttf',
    ]);
    await _loadFont('monospace', ['C:/Windows/Fonts/consola.ttf']);
    await _loadFont('Segoe UI Emoji', ['C:/Windows/Fonts/seguiemj.ttf']);
    await _loadFont('MaterialIcons', [
      'C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    ]);

    // Seed believable learner progress straight from the shipped content.
    final courses =
        (jsonDecode(
                  File('assets/content/courses.json').readAsStringSync(),
                )['courses']
                as List)
            .cast<Map<String, dynamic>>();
    final html = courses.first;
    final htmlSlug = html['slug'] as String;
    final htmlLessons = (html['lessons'] as List)
        .map((l) => l['slug'] as String)
        .toList();
    final css = courses[1];
    final cssSlug = css['slug'] as String;
    final cssLessons = (css['lessons'] as List)
        .map((l) => l['slug'] as String)
        .toList();

    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'jovexa-settings-theme': 'dark',
      'jovexa-learn-progress-v1': jsonEncode({
        'completed': [
          for (final l in htmlLessons.take(6)) '$htmlSlug/$l',
          for (final l in cssLessons.take(2)) '$cssSlug/$l',
        ],
        'quizScores': {htmlSlug: 6},
        'bookmarks': [
          '$htmlSlug/${htmlLessons[3]}',
          '$cssSlug/${cssLessons[1]}',
        ],
        'recent': [
          '$htmlSlug/${htmlLessons[6]}',
          '$cssSlug/${cssLessons[2]}',
          '$htmlSlug/${htmlLessons[5]}',
        ],
        'activeDays': [
          for (var i = 6; i >= 0; i--) _day(now.subtract(Duration(days: i))),
        ],
      }),
    });
    await ContentRepository.instance.load();
    await ProgressStore.instance.load();
    await SettingsStore.instance.load();
    Directory(_out).createSync(recursive: true);
  });

  Future<void> shoot(WidgetTester tester, String name) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // toImage only completes on the real async queue, not the fake test clock.
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: _dpr);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('store screenshots', (tester) async {
    tester.view.physicalSize = Size(
      _logical.width * _dpr,
      _logical.height * _dpr,
    );
    tester.view.devicePixelRatio = _dpr;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(key: key, child: const JovexaLearnApp()),
    );
    await tester.pumpAndSettle();
    await shoot(tester, '01_home');

    final course = ContentRepository.instance.courses.first;
    appRouter.go('/courses');
    await tester.pumpAndSettle();
    await shoot(tester, '02_courses');

    appRouter.go('/courses/${course.slug}');
    await tester.pumpAndSettle();
    await shoot(tester, '03_course');

    // A lesson that shows a code example.
    final lesson = course.lessons.firstWhere(
      (l) => l.sections.any((s) => s.code != null),
    );
    appRouter.go('/courses/${course.slug}/lesson/${lesson.slug}');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -420));
    await tester.pumpAndSettle();
    await shoot(tester, '04_lesson');

    appRouter.go('/courses/${course.slug}/quiz');
    await tester.pumpAndSettle();
    await shoot(tester, '05_quiz');

    appRouter.go('/reference');
    await tester.pumpAndSettle();
    await shoot(tester, '06_reference');

    appRouter.go('/my');
    await tester.pumpAndSettle();
    await shoot(tester, '07_my_learning');
  });
}
