import 'package:flutter/material.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Ung dung chinh quan ly ThemeMode (Sang / Toi) va he thong 3 Shell theo Role.
class BadmintonApp extends StatefulWidget {
  const BadmintonApp({super.key});

  @override
  State<BadmintonApp> createState() => _BadmintonAppState();
}

class _BadmintonAppState extends State<BadmintonApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: AppRoleShellHost(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
