import 'package:go_router/go_router.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/models/presentation/models_screen.dart';
import '../features/servers/presentation/server_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/servers',
  routes: [
    GoRoute(
      path: '/servers',
      name: 'servers',
      builder: (context, state) => const ServerScreen(),
    ),
    GoRoute(
      path: '/models',
      name: 'models',
      builder: (context, state) => const ModelsScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) {
        final conversationId = state.uri.queryParameters['conversation'];
        return ChatScreen(conversationId: conversationId);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
