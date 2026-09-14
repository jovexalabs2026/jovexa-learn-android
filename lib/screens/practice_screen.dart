import 'dart:math';

import 'package:flutter/material.dart';

import '../content_repository.dart';
import '../models.dart';
import '../widgets/exercise_card.dart';

/// Daily practice: a short randomized set of exercise questions drawn from
/// every lesson in the catalog, with an optional per-course topic filter.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const int _setSize = 5;

  final Random _random = Random();

  late final List<(Course, ExerciseQuestion)> _pool;
  late final List<String> _topics;

  String? _topic;
  List<(Course, ExerciseQuestion)> _current = [];
  List<Key> _cardKeys = [];
  int _correct = 0;
  int _answered = 0;

  @override
  void initState() {
    super.initState();
    _pool = [
      for (final course in ContentRepository.instance.courses)
        for (final lesson in course.lessons)
          if (lesson.exercise != null) (course, lesson.exercise!),
    ];
    _topics = [
      for (final course in ContentRepository.instance.courses)
        if (course.lessons.any((l) => l.exercise != null)) course.title,
    ];
    _shuffle();
  }

  List<(Course, ExerciseQuestion)> get _filteredPool => _topic == null
      ? _pool
      : [
          for (final pair in _pool)
            if (pair.$1.title == _topic) pair,
        ];

  void _shuffle() {
    final source = [..._filteredPool]..shuffle(_random);
    _current = source.take(_setSize).toList();
    _cardKeys = [for (final _ in _current) UniqueKey()];
    _correct = 0;
    _answered = 0;
  }

  void _selectTopic(String? topic) => setState(() {
    _topic = topic;
    _shuffle();
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Practice')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Five quick questions to keep your skills sharp.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('All topics'),
                  selected: _topic == null,
                  onSelected: (_) => _selectTopic(null),
                ),
                for (final topic in _topics)
                  FilterChip(
                    label: Text(topic),
                    selected: _topic == topic,
                    onSelected: (_) => _selectTopic(topic),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Correct: $_correct of $_answered answered',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (_current.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No practice questions are available for this topic yet.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              )
            else
              for (var i = 0; i < _current.length; i++)
                ExerciseCard(
                  key: _cardKeys[i],
                  question: _current[i].$2,
                  title: _current[i].$1.title,
                  onAnswered: (correct) => setState(() {
                    _answered++;
                    if (correct) _correct++;
                  }),
                ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(_shuffle),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('New set'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
