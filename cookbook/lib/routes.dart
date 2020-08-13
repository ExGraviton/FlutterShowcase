import 'package:flutter/material.dart';

import 'meal_db.dart';
import 'screens/cookbook_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipes_screen.dart';

class Routes {
  static const home = 'home';
  static const recipes = 'recipes';
  static const cookbook = 'cookbook';
}

Route onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return MaterialPageRoute<void>(
        builder: (context) => const HomeScreen(),
      );
    case Routes.recipes:
      return MaterialPageRoute<void>(
        builder: (context) => RecipesScreen(
          category: settings.arguments as Category,
        ),
      );
    case Routes.cookbook:
      return MaterialPageRoute<void>(
        builder: (context) => CookbookScreen(
          mealShort: settings.arguments as MealShort,
        ),
      );
  }

  return null;
}
