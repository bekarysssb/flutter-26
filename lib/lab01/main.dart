import 'package:flutter/material.dart';

import 'router.dart';
import 'routes.dart';
import 'shell.dart';

void main() => runApp(const MyApp());

/// The one seed colour of the app; every other colour comes from the
/// ColorScheme built from it.
const seedColor = Color(0xFF00695C);

ThemeData buildTheme(Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
    );

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // R11: ThemeMode lives above MaterialApp and reaches the profile tab
  // through the shell as a parameter plus a callback.
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Campus Events',
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: _mode,
        routes: {
          Routes.home: (_) => Shell(
                themeMode: _mode,
                onThemeMode: (m) => setState(() => _mode = m),
              ),
        },
        onGenerateRoute: onGenerateRoute,
        onUnknownRoute: onUnknownRoute,
      );
}
