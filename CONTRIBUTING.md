# Contributing to Jovexa Learn for Android

Thanks for your interest in improving Jovexa Learn. Contributions of all sizes are welcome.

## Ground rules

1. **Originality is non-negotiable.** Every lesson, exercise, quiz question, and reference entry must be written from scratch. Never copy or closely paraphrase text, examples, or structure from other learning platforms.
2. **Accuracy matters.** Code examples must run as written. Quiz answers must be correct and explanations must teach, not just confirm.
3. **Keep the tone professional and friendly.** Short sentences, plain language, no filler.
4. **No em dashes** in any user-facing copy. Use commas or periods.
5. **Privacy first.** No analytics, tracking, accounts, or data collection. Progress stays on the device.
6. **No secrets.** Never commit API keys, keystores, or production ad unit IDs.

## Development setup

```bash
flutter pub get
flutter run
```

Before opening a pull request:

```bash
flutter analyze   # must report no issues
flutter test      # must pass
```

## Content changes

Content lives in `assets/content/*.json` and is exported from the jovexalabs.com repository, which is the source of truth for the curriculum. For lesson or course changes, contribute there; the JSON here is regenerated from it. Small fixes (typos, wrong answers) can be proposed directly against the JSON, but flag them so the source repository is updated too.

Content schema, per course: `slug`, `title`, `icon`, `category`, `level`, `estimatedHours`, `tagline`, `description`, `lessons[]`, `quiz[]`. Each lesson: `slug`, `title`, `objective`, `sections[]` (heading, text, optional code and language), `mistakes[]`, and an optional `exercise` (question, options, answer index, explanation).

`test/content_test.dart` enforces the schema. Run it after any content change.

## Code changes

- Follow the existing structure: models in `lib/models.dart`, data access in `lib/content_repository.dart`, state in the store classes, screens in `lib/screens/`.
- State management is deliberately lightweight: `ChangeNotifier` singletons, no additional frameworks.
- Match the existing Material 3 styling and support both dark and light themes.
- Keep screens overflow-safe on small phones and readable at large font scales.

## Pull requests

- Branch from `main`, use a descriptive branch name.
- Use conventional commit messages, for example `feat: add reference entries for CSS grid` or `fix: correct quiz answer in git basics`.
- Describe what changed and why. Screenshots are appreciated for UI changes.

## Reporting issues

Open a GitHub issue with steps to reproduce, expected behavior, and actual behavior. For security concerns, see [SECURITY.md](SECURITY.md).
