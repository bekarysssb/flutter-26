import 'package:flutter/material.dart';

import 'models/campus_event.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: detail and form are built from typed argument classes.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments as DetailArgs;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
    case Routes.form:
      final args = settings.arguments as FormArgs;
      return MaterialPageRoute<CampusEvent>(
        settings: settings,
        builder: (_) => FormScreen(event: args.event),
      );
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Not found')),
      ),
    );
