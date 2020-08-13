import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../meal_db.dart';
import '../routes.dart';
import '../widgets/cached_image.dart';
import '../widgets/loading_indicators.dart';
import 'common/recipe_preview.dart';

class CategoriesScreen extends HookWidget {
  const CategoriesScreen({Key key}) : super(key: key);

  @override
  Widget build(context) {
    final db = context.watch<MealDB>();

    final categories = useFuture(db.category).data;
    final randomMeals = useFuture(db.randoms).data;

    final categoryHeaderStyle = Theme.of(context).textTheme.caption;

    return LayoutBuilder(
      builder: (context, constraints) {
        const fraction = .7;
        final width = constraints.maxWidth;

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  'DISCOVER',
                  style: categoryHeaderStyle,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  controller: PageController(viewportFraction: fraction),
                  physics: const PageScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: randomMeals?.length ?? 4,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  itemBuilder: (c, i) => SizedBox(
                    width: width * fraction,
                    child: RecipePreview(
                      meal: randomMeals?.elementAt(i),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'CATEGORIES',
                  style: categoryHeaderStyle,
                ),
              ),
            ),
            SliverFixedExtentList(
              itemExtent: 100,
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _CategoryPreview(category: categories?.elementAt(index)),
                childCount: categories?.length ?? 10,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPreview extends StatelessWidget {
  const _CategoryPreview({
    @required this.category, // nullable
    Key key,
  }) : super(key: key);
  final Category category;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    final titleStyle = textTheme.headline5;
    final descriptionStyle =
        textTheme.headline6.copyWith(fontWeight: FontWeight.w300);

    const categoryThumbAspectRatio = 320 / 200;

    return InkWell(
      onTap: category == null
          ? null
          : () {
              Navigator.of(context)
                  .pushNamed(Routes.recipes, arguments: category);
            },
      child: Padding(
        padding: padding8,
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: categoryThumbAspectRatio,
              child: ClipRRect(
                borderRadius: borderRadius16,
                child: CachedImage(
                  imageUrl: category?.thumb,
                  fit: BoxFit.cover,
                  placeholder: const LoadingShimmer(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextOrBlock(
                    category?.name,
                    style: titleStyle,
                  ),
                  TextOrBlock(
                    category?.description,
                    lines: 2,
                    style: descriptionStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
