import 'package:go_router/go_router.dart';

import 'app_navigation_shell.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/models/presentation/models_screen.dart';
import '../features/servers/presentation/server_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/chat',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppNavigationShell(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => ChatScreen(
                conversationId: state.uri.queryParameters['conversation'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/servers',
              name: 'servers',
              builder: (context, state) => const ServerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/models',
              name: 'models',
              builder: (context, state) => const ModelsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
