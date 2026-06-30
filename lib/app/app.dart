import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class OllamaMobileApp extends StatelessWidget {
  const OllamaMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BytePapo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
