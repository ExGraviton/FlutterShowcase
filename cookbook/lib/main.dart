import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meal_db.dart';
import 'prefs.dart';
import 'routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = Prefs(await SharedPreferences.getInstance());

  runApp(CookbookApp(prefs: prefs));
}

class CookbookApp extends StatelessWidget {
  const CookbookApp({@required this.prefs, Key key})
      : assert(prefs != null),
        super(key: key);
  final Prefs prefs;

  @override
  Widget build(context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MealDB()),
        ChangeNotifierProvider.value(value: prefs)
      ],
      builder: (context, _) {
        final prefs = context.watch<Prefs>();
        return MaterialApp(
          theme: prefs.isDark ? darkTheme : lightTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: onGenerateRoute,
          initialRoute: Routes.home,
          builder: (context, child) => ScrollConfiguration(
            behavior: const _ScrollBehavior(),
            child: child,
          ),
        );
      },
    );
  }
}

class _ScrollBehavior extends ScrollBehavior {
  const _ScrollBehavior();
  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;

  @override
  ScrollPhysics getScrollPhysics(context) => const BouncingScrollPhysics();
}
