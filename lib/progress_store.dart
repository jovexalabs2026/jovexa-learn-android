import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local progress tracking. Everything is stored on the device with
/// shared_preferences as a single JSON document. No account, no network.
class ProgressStore extends ChangeNotifier {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  static const _key = 'jovexa-learn-progress-v1';

  SharedPreferences? _prefs;

  Set<String> _completed = {};
  Map<String, int> _quizScores = {};
  Set<String> _bookmarks = {};
  List<String> _recent = [];
  List<String> _activeDays = [];

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _completed = ((data['completed'] as List?) ?? const [])
            .cast<String>()
            .toSet();
        _quizScores = ((data['quizScores'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(k as String, (v as num).toInt()),
        );
        _bookmarks = ((data['bookmarks'] as List?) ?? const [])
            .cast<String>()
            .toSet();
        _recent = ((data['recent'] as List?) ?? const [])
            .cast<String>()
            .toList();
        _activeDays = ((data['activeDays'] as List?) ?? const [])
            .cast<String>()
            .toList();
      } catch (_) {
        // Corrupt data resets progress rather than crashing the app.
      }
    }
    _markActiveToday(save: raw == null);
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefs?.setString(
      _key,
      jsonEncode({
        'completed': _completed.toList(),
        'quizScores': _quizScores,
        'bookmarks': _bookmarks.toList(),
        'recent': _recent,
        'activeDays': _activeDays,
      }),
    );
  }

  static String lessonKey(String courseSlug, String lessonSlug) =>
      '$courseSlug/$lessonSlug';

  // Lesson completion -------------------------------------------------------

  bool isLessonComplete(String courseSlug, String lessonSlug) =>
      _completed.contains(lessonKey(courseSlug, lessonSlug));

  Future<void> toggleLessonComplete(
    String courseSlug,
    String lessonSlug,
  ) async {
    final key = lessonKey(courseSlug, lessonSlug);
    if (!_completed.remove(key)) _completed.add(key);
    await _save();
    notifyListeners();
  }

  int completedCount(String courseSlug) =>
      _completed.where((k) => k.startsWith('$courseSlug/')).length;

  int get totalCompleted => _completed.length;

  // Quiz scores -------------------------------------------------------------

  Future<void> setQuizScore(String courseSlug, int score) async {
    final prev = _quizScores[courseSlug];
    if (prev == null || score > prev) {
      _quizScores[courseSlug] = score;
      await _save();
      notifyListeners();
    }
  }

  int? quizScore(String courseSlug) => _quizScores[courseSlug];

  // Bookmarks ---------------------------------------------------------------

  bool isBookmarked(String courseSlug, String lessonSlug) =>
      _bookmarks.contains(lessonKey(courseSlug, lessonSlug));

  Future<void> toggleBookmark(String courseSlug, String lessonSlug) async {
    final key = lessonKey(courseSlug, lessonSlug);
    if (!_bookmarks.remove(key)) _bookmarks.add(key);
    await _save();
    notifyListeners();
  }

  List<String> get bookmarks => _bookmarks.toList();

  // Recently visited --------------------------------------------------------

  Future<void> recordVisit(String courseSlug, String lessonSlug) async {
    final key = lessonKey(courseSlug, lessonSlug);
    _recent.remove(key);
    _recent.insert(0, key);
    if (_recent.length > 12) _recent = _recent.sublist(0, 12);
    _markActiveToday();
    await _save();
    notifyListeners();
  }

  List<String> get recent => List.unmodifiable(_recent);

  // Learning streak ---------------------------------------------------------

  static String _dayString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _markActiveToday({bool save = true}) {
    final today = _dayString(DateTime.now());
    if (!_activeDays.contains(today)) {
      _activeDays.add(today);
      if (_activeDays.length > 400) {
        _activeDays = _activeDays.sublist(_activeDays.length - 400);
      }
      if (save) _save();
    }
  }

  /// Consecutive active days ending today (or yesterday, so an early-morning
  /// open does not show zero before the user studies).
  int get streak {
    final days = _activeDays.toSet();
    var cursor = DateTime.now();
    if (!days.contains(_dayString(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(_dayString(cursor))) return 0;
    }
    var count = 0;
    while (days.contains(_dayString(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  // Reset -------------------------------------------------------------------

  Future<void> clearAll() async {
    _completed = {};
    _quizScores = {};
    _bookmarks = {};
    _recent = [];
    _activeDays = [];
    _markActiveToday(save: false);
    await _save();
    notifyListeners();
  }
}
