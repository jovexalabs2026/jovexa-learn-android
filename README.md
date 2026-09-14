# Jovexa Learn for Android

Free, offline-first coding education by [Jovexa Labs](https://jovexalabs.com). Learn code. Build skills. Create more.

Jovexa Learn brings the full Jovexa Learn curriculum to Android: 7 courses, 61 lessons, quizzes, daily practice, guided learning paths, a 77-entry quick reference, and a real HTML, CSS, and JavaScript playground that runs entirely on your device.

## Features

- **Courses**: HTML, CSS, JavaScript, Python, SQL, Git, and Flutter, written from scratch for Jovexa Learn. Every lesson has an objective, explanations, code examples, common mistakes, and a practice exercise.
- **Quizzes**: every course ends with a quiz. Score 70% or higher to pass. Best scores are saved.
- **Code Lab**: a live playground for HTML, CSS, and JavaScript. Code runs locally in a sandboxed WebView with all outbound navigation blocked. No fake execution: languages that cannot run on the device are presented as read-only examples.
- **Daily Practice**: randomized exercise sets with topic filters.
- **Learning Paths**: guided step-by-step routes across courses.
- **Reference**: searchable quick reference for common syntax and commands.
- **My Learning**: progress per course, learning streak, quiz scores, recently viewed, and bookmarks.
- **Offline first**: all content ships inside the app as bundled JSON. Progress is stored on the device only. No account, no tracking, no data collection.
- **Themes**: dark, light, or follow system, plus adjustable reading and code font sizes.

## Tech stack

- Flutter (Dart), Material 3
- go_router for navigation
- shared_preferences for local progress and settings
- webview_flutter for the sandboxed Code Lab
- url_launcher for outbound links

Package name: `com.jovexalabs.learn`

## Getting started

```bash
git clone https://github.com/jovexalabs2026/jovexa-learn-android.git
cd jovexa-learn-android
flutter pub get
flutter run
```

Requires Flutter 3.35 or newer.

### Tests

```bash
flutter analyze
flutter test
```

The suite covers content integrity (slugs, quiz answer indexes, path references), the progress store (completion, quiz scores, bookmarks, recents, streak, persistence), and app navigation.

### Release build

```bash
flutter build appbundle --release
```

The checked-in Gradle config signs release builds with the debug key so local release builds work out of the box. Publishing to Google Play requires your own upload keystore, configured locally and never committed.

## Content pipeline

Learning content is authored in the [jovexalabs.com](https://github.com/jovexalabs2026/jovexalabs.com) repository and exported to `assets/content/*.json`. The app treats content as data, so updating the curriculum is a JSON swap plus a release.

## Ads

The app currently ships with ads fully disabled. `lib/ads_service.dart` is a no-op integration point; production ad unit IDs are never committed and would be injected at build time with `--dart-define`. Only Google's published TEST IDs may appear in source.

## Privacy

Jovexa Learn stores progress only on your device and requests a single permission (INTERNET, used for outbound links and future ad serving).

- [Privacy Policy](https://jovexalabs.com/privacy)
- [Terms of Use](https://jovexalabs.com/terms)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All content must be 100% original. Never copy text from other learning platforms.

## License

[MIT](LICENSE). Jovexa brand assets (name, logo, icons) are trademarks of Jovexa Software Development Services and are not covered by the code license.
