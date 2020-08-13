import 'package:flutter/material.dart';

class _PageTransitionsTheme extends PageTransitionsTheme {
  const _PageTransitionsTheme();
  @override
  Widget buildTransitions<T>(
      route, context, animation, secondaryAnimation, child) {
    return const OpenUpwardsPageTransitionsBuilder().buildTransitions<T>(
        route, context, animation, secondaryAnimation, child);
  }
}

final _primarySwatch = Colors.brown;
final _splashColor = _primarySwatch.shade300.withOpacity(.3);
final _highlightColor = _primarySwatch.shade300.withOpacity(.2);

final lightTheme = ThemeData(
  splashColor: _splashColor,
  highlightColor: _highlightColor,
  primarySwatch: _primarySwatch,
  brightness: Brightness.light,
  pageTransitionsTheme: const _PageTransitionsTheme(),
);

final darkTheme = ThemeData(
  splashColor: _splashColor,
  highlightColor: _highlightColor,
  primarySwatch: _primarySwatch,
  brightness: Brightness.dark,
  pageTransitionsTheme: const _PageTransitionsTheme(),
);
