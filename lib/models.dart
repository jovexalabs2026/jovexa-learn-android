// Content models for Jovexa Learn. All content ships as bundled JSON assets,
// so the whole learning experience works offline.

class LessonSection {
  final String heading;
  final String text;
  final String? code;
  final String? language;

  const LessonSection({
    required this.heading,
    required this.text,
    this.code,
    this.language,
  });

  factory LessonSection.fromJson(Map<String, dynamic> json) => LessonSection(
    heading: json['heading'] as String,
    text: json['text'] as String,
    code: json['code'] as String?,
    language: json['language'] as String?,
  );
}

class ExerciseQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  const ExerciseQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) =>
      ExerciseQuestion(
        question: json['question'] as String,
        options: (json['options'] as List).cast<String>(),
        answer: json['answer'] as int,
        explanation: json['explanation'] as String,
      );
}

class Lesson {
  final String slug;
  final String title;
  final String objective;
  final List<LessonSection> sections;
  final List<String> mistakes;
  final ExerciseQuestion? exercise;

  const Lesson({
    required this.slug,
    required this.title,
    required this.objective,
    required this.sections,
    required this.mistakes,
    this.exercise,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    slug: json['slug'] as String,
    title: json['title'] as String,
    objective: (json['objective'] as String?) ?? '',
    sections: (json['sections'] as List)
        .map((s) => LessonSection.fromJson(s as Map<String, dynamic>))
        .toList(),
    mistakes: ((json['mistakes'] as List?) ?? const []).cast<String>(),
    exercise: json['exercise'] == null
        ? null
        : ExerciseQuestion.fromJson(json['exercise'] as Map<String, dynamic>),
  );
}

class Course {
  final String slug;
  final String title;
  final String icon;
  final String category;
  final String level;
  final int estimatedHours;
  final String tagline;
  final String description;
  final List<Lesson> lessons;
  final List<ExerciseQuestion> quiz;

  const Course({
    required this.slug,
    required this.title,
    required this.icon,
    required this.category,
    required this.level,
    required this.estimatedHours,
    required this.tagline,
    required this.description,
    required this.lessons,
    required this.quiz,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    slug: json['slug'] as String,
    title: json['title'] as String,
    icon: json['icon'] as String,
    category: (json['category'] as String?) ?? 'General',
    level: json['level'] as String,
    estimatedHours: (json['estimatedHours'] as num?)?.toInt() ?? 2,
    tagline: json['tagline'] as String,
    description: json['description'] as String,
    lessons: (json['lessons'] as List)
        .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
        .toList(),
    quiz: ((json['quiz'] as List?) ?? const [])
        .map((q) => ExerciseQuestion.fromJson(q as Map<String, dynamic>))
        .toList(),
  );
}

class ReferenceEntry {
  final String id;
  final String category;
  final String name;
  final String description;
  final String example;

  const ReferenceEntry({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.example,
  });

  factory ReferenceEntry.fromJson(Map<String, dynamic> json) => ReferenceEntry(
    id: json['id'] as String,
    category: json['category'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    example: json['example'] as String,
  );
}

class PathStep {
  final String title;
  final String? course;
  final String? lesson;
  final String? note;

  const PathStep({required this.title, this.course, this.lesson, this.note});

  factory PathStep.fromJson(Map<String, dynamic> json) => PathStep(
    title: json['title'] as String,
    course: json['course'] as String?,
    lesson: json['lesson'] as String?,
    note: json['note'] as String?,
  );
}

class LearnPath {
  final String slug;
  final String title;
  final String icon;
  final String description;
  final List<PathStep> steps;

  const LearnPath({
    required this.slug,
    required this.title,
    required this.icon,
    required this.description,
    required this.steps,
  });

  factory LearnPath.fromJson(Map<String, dynamic> json) => LearnPath(
    slug: json['slug'] as String,
    title: json['title'] as String,
    icon: json['icon'] as String,
    description: json['description'] as String,
    steps: (json['steps'] as List)
        .map((s) => PathStep.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
