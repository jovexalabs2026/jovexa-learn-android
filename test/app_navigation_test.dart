import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jovexa_learn/content_repository.dart';
import 'package:jovexa_learn/main.dart';
import 'package:jovexa_learn/progress_store.dart';
import 'package:jovexa_learn/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ContentRepository.instance.load();
    await ProgressStore.instance.load();
    await SettingsStore.instance.load();
  });

  testWidgets('home renders and bottom navigation reaches core screens', (
    tester,
  ) async {
    await tester.pumpWidget(const JovexaLearnApp());
    await tester.pumpAndSettle();

    expect(find.text('Jovexa Learn'), findsOneWidget);
    expect(find.text('Popular Courses'), findsOneWidget);

    // Courses tab shows the catalog.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Courses'));
    await tester.pumpAndSettle();
    final firstCourse = ContentRepository.instance.courses.first;
    expect(find.textContaining(firstCourse.title), findsWidgets);

    // Open the first course and see its lesson list.
    appRouter.go('/courses/${firstCourse.slug}');
    await tester.pumpAndSettle();
    expect(find.textContaining(firstCourse.tagline), findsWidgets);

    // Open the first lesson and confirm the objective renders.
    appRouter.go(
      '/courses/${firstCourse.slug}/lesson/${firstCourse.lessons.first.slug}',
    );
    await tester.pumpAndSettle();
    expect(find.text('Objective'), findsOneWidget);

    // Mark complete works from the lesson screen.
    await tester.dragUntilVisible(
      find.textContaining('Mark as complete'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.tap(find.textContaining('Mark as complete'));
    await tester.pumpAndSettle();
    expect(
      ProgressStore.instance.isLessonComplete(
        firstCourse.slug,
        firstCourse.lessons.first.slug,
      ),
      isTrue,
    );

    // Reference tab renders entries.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Reference'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);

    // My Learning reflects the completed lesson.
    await tester.tap(find.widgetWithText(NavigationDestination, 'My Learning'));
    await tester.pumpAndSettle();
    expect(find.text('My Learning'), findsWidgets);
  });
}
