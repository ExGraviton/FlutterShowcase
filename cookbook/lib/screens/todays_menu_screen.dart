import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../hooks.dart';
import '../meal_db.dart';
import 'common/recipe_preview.dart';

class TodaysMenuScreen extends HookWidget {
  const TodaysMenuScreen({Key key}) : super(key: key);

  static final _todaysSeed = () {
    final now = DateTime.now();
    return now.year << 16 + now.month << 8 + now.day;
  }();

  Future<MealShort> _randomMeal(MealDB db, List<String> categories,
      [int seed]) async {
    final random = math.Random(seed ?? _todaysSeed);
    final category = categories[random.nextInt(categories.length)];
    final meals = await db.getMealsFromCategory(category);
    return meals[random.nextInt(meals.length)];
  }

  @override
  Widget build(context) {
    final db = context.watch<MealDB>();

    final breakfast = useMemoizedFuture(
      () => _randomMeal(db, const ['Breakfast', 'Pasta']),
    ).data;
    final lunch = useMemoizedFuture(
      () => _randomMeal(db, const ['Vegetarian']),
    ).data;
    final dinner = useMemoizedFuture(
      () =>
          _randomMeal(db, const ['Beef', 'Chicken', 'Lamb', 'Seafood', 'Pork']),
    ).data;
    final dessert = useMemoizedFuture(
      () => _randomMeal(db, const ['Dessert']),
    ).data;
    final side = useMemoizedFuture(
      () => _randomMeal(db, const ['Side']),
    ).data;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Padding buildTitle(String title) {
      return Padding(
        padding: padding8,
        child: Text(
          title,
          style: theme.textTheme.caption,
        ),
      );
    }

    Padding buildDecoratedTitle(String title) {
      const lightDecoration = ShapeDecoration(
          shape: shapeBorder8,
          gradient:
              LinearGradient(colors: [Color(0xaacea992), Color(0x00ffffff)]));
      const darkDecoration = ShapeDecoration(
          shape: shapeBorder8,
          gradient:
              LinearGradient(colors: [Color(0x62ffffff), Color(0x00000000)]));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DecoratedBox(
          decoration: isDark ? darkDecoration : lightDecoration,
          child: buildTitle(title),
        ),
      );
    }

    return ListView(
      padding: padding8,
      children: <Widget>[
        buildDecoratedTitle('BREAKFAST'),
        SizedBox(
          height: 200,
          child: RecipePreview(meal: breakfast),
        ),
        buildDecoratedTitle('LUNCH'),
        SizedBox(
          height: 200,
          child: RecipePreview(meal: lunch),
        ),
        buildDecoratedTitle('DINNER'),
        SizedBox(
          height: 200,
          child: RecipePreview(meal: dinner),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildTitle('DESSERT'),
                  SizedBox(
                    height: 150,
                    child: RecipePreview(meal: dessert),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildTitle('SIDE'),
                  SizedBox(
                    height: 150,
                    child: RecipePreview(meal: side),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
