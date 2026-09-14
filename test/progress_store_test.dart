import 'package:flutter_test/flutter_test.dart';
import 'package:jovexa_learn/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProgressStore.instance.clearAll();
    await ProgressStore.instance.load();
  });

  test('lesson completion toggles and counts per course', () async {
    final store = ProgressStore.instance;
    expect(store.isLessonComplete('html', 'intro'), isFalse);
    await store.toggleLessonComplete('html', 'intro');
    expect(store.isLessonComplete('html', 'intro'), isTrue);
    await store.toggleLessonComplete('html', 'links');
    expect(store.completedCount('html'), 2);
    expect(store.completedCount('css'), 0);
    expect(store.totalCompleted, 2);
    await store.toggleLessonComplete('html', 'intro');
    expect(store.isLessonComplete('html', 'intro'), isFalse);
    expect(store.completedCount('html'), 1);
  });

  test('quiz score keeps the best result', () async {
    final store = ProgressStore.instance;
    expect(store.quizScore('css'), isNull);
    await store.setQuizScore('css', 4);
    await store.setQuizScore('css', 2);
    expect(store.quizScore('css'), 4);
    await store.setQuizScore('css', 6);
    expect(store.quizScore('css'), 6);
  });

  test('bookmarks toggle on and off', () async {
    final store = ProgressStore.instance;
    await store.toggleBookmark('javascript', 'functions');
    expect(store.isBookmarked('javascript', 'functions'), isTrue);
    expect(store.bookmarks, contains('javascript/functions'));
    await store.toggleBookmark('javascript', 'functions');
    expect(store.isBookmarked('javascript', 'functions'), isFalse);
  });

  test('recent visits deduplicate and cap at 12', () async {
    final store = ProgressStore.instance;
    for (var i = 0; i < 15; i++) {
      await store.recordVisit('html', 'lesson-$i');
    }
    await store.recordVisit('html', 'lesson-3');
    expect(store.recent.length, 12);
    expect(store.recent.first, 'html/lesson-3');
    expect(store.recent.where((k) => k == 'html/lesson-3').length, 1);
  });

  test('streak counts today as active after any visit', () async {
    final store = ProgressStore.instance;
    await store.recordVisit('html', 'intro');
    expect(store.streak, greaterThanOrEqualTo(1));
  });

  test('clearAll resets everything and persists across reload', () async {
    final store = ProgressStore.instance;
    await store.toggleLessonComplete('html', 'intro');
    await store.setQuizScore('html', 5);
    await store.toggleBookmark('html', 'intro');
    await store.clearAll();
    expect(store.totalCompleted, 0);
    expect(store.quizScore('html'), isNull);
    expect(store.bookmarks, isEmpty);
    expect(store.recent, isEmpty);

    // Persistence round trip: completing then reloading keeps state.
    await store.toggleLessonComplete('sql', 'select');
    await store.load();
    expect(store.isLessonComplete('sql', 'select'), isTrue);
  });
}
