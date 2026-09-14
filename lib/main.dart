import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ads_service.dart';
import 'content_repository.dart';
import 'progress_store.dart';
import 'screens/course_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/my_learning_screen.dart';
import 'screens/paths_screen.dart';
import 'screens/playground_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/reference_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'settings_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ContentRepository.instance.load();
  await ProgressStore.instance.load();
  await SettingsStore.instance.load();
  await AdsService.instance.initialize();
  runApp(const JovexaLearnApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/courses',
              builder: (context, state) => const CoursesScreen(),
              routes: [
                GoRoute(
                  path: ':courseSlug',
                  builder: (context, state) => CourseScreen(
                    courseSlug: state.pathParameters['courseSlug']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'quiz',
                      builder: (context, state) => QuizScreen(
                        courseSlug: state.pathParameters['courseSlug']!,
                      ),
                    ),
                    GoRoute(
                      path: 'lesson/:lessonSlug',
                      builder: (context, state) => LessonScreen(
                        courseSlug: state.pathParameters['courseSlug']!,
                        lessonSlug: state.pathParameters['lessonSlug']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/playground',
              builder: (context, state) => const PlaygroundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reference',
              builder: (context, state) => const ReferenceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my',
              builder: (context, state) => const MyLearningScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/paths',
      builder: (context, state) => const PathsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/practice',
      builder: (context, state) => const PracticeScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);

class JovexaLearnApp extends StatelessWidget {
  const JovexaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsStore.instance,
      builder: (context, _) {
        final settings = SettingsStore.instance;
        return MaterialApp.router(
          title: 'Jovexa Learn',
          debugShowCheckedModeBanner: false,
          theme: JovexaTheme.light(),
          darkTheme: JovexaTheme.dark(),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(settings.fontScale)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final banner = AdsService.instance.bannerFor('shell');
    return Scaffold(
      body: shell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?banner,
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Courses',
              ),
              NavigationDestination(
                icon: Icon(Icons.code_rounded),
                selectedIcon: Icon(Icons.code_rounded),
                label: 'Code Lab',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article_rounded),
                label: 'Reference',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'My Learning',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
