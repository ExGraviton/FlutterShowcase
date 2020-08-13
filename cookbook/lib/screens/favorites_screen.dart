import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../hooks.dart';
import '../meal_db.dart';
import '../prefs.dart';
import '../widgets/loading_indicators.dart';
import 'common/recipe_preview.dart';

class FavoritesScreen extends HookWidget {
  const FavoritesScreen({Key key}) : super(key: key);

  @override
  Widget build(context) {
    final db = context.watch<MealDB>();
    final favorites = context.watch<Prefs>().favorites;
    final meals = useMemoizedFuture(
      () => Future.wait(favorites.map(db.getMeal)),
      favorites,
    ).data;

    if (meals?.isEmpty ?? false) {
      return const NoItemIndicator(
        icon: Icons.favorite_border,
        text: 'Add something to favorites',
      );
    }
    return ListView.builder(
      itemExtent: 200,
      padding: padding8,
      itemCount: meals?.length ?? 10,
      itemBuilder: (context, index) => RecipePreview(
        meal: meals?.elementAt(index),
      ),
    );
  }
}
