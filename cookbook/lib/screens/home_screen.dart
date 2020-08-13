import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../meal_db.dart';
import '../prefs.dart';
import '../widgets/loading_indicators.dart';
import 'categories_screen.dart';
import 'common/recipe_preview.dart';
import 'favorites_screen.dart';
import 'todays_menu_screen.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key key}) : super(key: key);

  String getTitle(int page) {
    switch (page) {
      case 0:
        return 'Cookbook';
      case 1:
        return 'Favorites';
      case 2:
        return "Today's Menu";
    }
    throw Exception('Unhandled page $page');
  }

  @override
  Widget build(context) {
    final index = useState(0);
    final title = getTitle(index.value);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _SearchDelegate());
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: index.value,
        children: const [
          CategoriesScreen(),
          FavoritesScreen(),
          TodaysMenuScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (value) => index.value = value,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), title: Text('Favorites')),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant), title: Text("Today's Menu")),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  static final packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(context) {
    final prefs = context.watch<Prefs>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Assets.drawerImage,
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Cookbook',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          SwitchListTile(
            value: prefs.isDark,
            onChanged: (value) => prefs.isDark = value,
            secondary: const Icon(Icons.brightness_medium),
            title: const Text('Dark Mode'),
          ),
          SwitchListTile(
            value: prefs.slowMotion,
            onChanged: (value) => prefs.slowMotion = value,
            secondary: const Icon(Icons.slow_motion_video),
            title: const Text('Slow Motion'),
          ),
          HookBuilder(builder: (context) {
            final info = useFuture(packageInfo).data;
            return AboutListTile(
              applicationName: info?.appName,
              applicationVersion: info?.version,
              applicationIcon: Container(
                width: 96,
                height: 96,
                padding: padding8,
                child: const Image(image: Assets.iconImage),
              ),
              icon: const Icon(Icons.info_outline),
            );
          }),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          close(context, null);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const Icon(Icons.search);
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      primaryColor: isDark ? null : Colors.white,
      primaryColorBrightness: isDark ? Brightness.dark : Brightness.light,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
    );
  }

  List<MealShort> _oldSuggestions = [];
  @override
  Widget buildSuggestions(BuildContext context) {
    final db = Provider.of<MealDB>(context, listen: false);
    final result = db.search(query);

    return HookBuilder(
      key: ValueKey(query),
      builder: (context) {
        final snapshot = useFuture(result);
        if (snapshot.hasData) {
          _oldSuggestions = snapshot.data;
        }
        if (snapshot?.data?.isEmpty ?? false) {
          return const NoItemIndicator(
            icon: Icons.search,
            text: 'Nothing found',
          );
        }
        return Stack(
          children: <Widget>[
            ListView(
              itemExtent: 200,
              padding: padding8,
              children: [
                for (final meal in _oldSuggestions) RecipePreview(meal: meal),
              ],
            ),
            if (!snapshot.hasData) const LinearProgressIndicator(),
          ],
        );
      },
    );
  }
}
