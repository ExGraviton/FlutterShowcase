import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../meal_db.dart';
import '../widgets/cached_image.dart';
import 'common/recipe_preview.dart';

class RecipesScreen extends HookWidget {
  const RecipesScreen({@required this.category, Key key})
      : assert(category != null),
        super(key: key);
  final Category category;

  @override
  Widget build(context) {
    final db = context.watch<MealDB>();
    final meals = useFuture(db.getMealsFromCategory(category.name)).data;
    const padding = 16.0;
    return Scaffold(
      body: CustomScrollView(
        controller: ScrollController(initialScrollOffset: 200 - kToolbarHeight),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            elevation: 8,
            forceElevated: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(category.name),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Transform.scale(
                    scale: 2,
                    child: Image(
                      image: ResizeImage(
                        CachedImageProvider(category.thumb),
                        width: 8,
                        height: 8,
                      ),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  CachedImage(
                    imageUrl: category.thumb,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                  const Positioned(
                    height: 64,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: padding),
          ),
          SliverFixedExtentList(
            itemExtent: 200,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RecipePreview(
                  meal: meals?.elementAt(index),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                );
              },
              childCount: meals?.length ?? 5,
            ),
          ),
        ],
      ),
    );
  }
}
