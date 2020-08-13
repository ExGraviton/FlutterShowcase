import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../meal_db.dart';
import '../../routes.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/loading_indicators.dart';

class RecipePreview extends StatelessWidget {
  const RecipePreview({
    @required this.meal, // nullable
    this.padding = padding8,
    Key key,
  }) : super(key: key);
  final MealShort meal;
  final EdgeInsetsGeometry padding;

  void onTap(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.cookbook, arguments: meal);
  }

  Widget buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final barText = meal == null
        ? const SizedBox()
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                meal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.headline5.copyWith(color: Colors.white),
              ),
            ),
          );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: meal == null ? null : () => onTap(context),
        child: FractionallySizedBox(
          heightFactor: .25,
          alignment: Alignment.bottomCenter,
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: ColoredBox(
                color: theme.primaryColorDark.withOpacity(.3),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: barText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    final onePixel = 1 / MediaQuery.of(context).devicePixelRatio;
    return Card(
      margin: padding,
      elevation: 8,
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(onePixel),
            child: ClipRRect(
              borderRadius: borderRadius8,
              child: CachedImage(
                imageUrl: meal?.thumb,
                placeholder: const LoadingShimmer(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: borderRadius8,
            child: buildBottomBar(context),
          ),
        ],
      ),
    );
  }
}
