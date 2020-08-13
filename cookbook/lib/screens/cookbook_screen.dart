import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../constants.dart';
import '../hooks.dart';
import '../meal_db.dart';
import '../prefs.dart';
import '../widgets/cached_image.dart';
import '../widgets/loading_indicators.dart';

class CookbookScreen extends HookWidget {
  const CookbookScreen({
    Key key,
    @required this.mealShort,
  })  : assert(mealShort != null),
        super(key: key);
  final MealShort mealShort;

  @override
  Widget build(context) {
    final db = context.watch<MealDB>();
    final meal = useFuture(db.getMeal(mealShort.id)).data;

    return Scaffold(
      appBar: AppBar(
        title: Text(mealShort.name),
        actions: <Widget>[
          if (meal != null) _FavoriteButton(meal: meal),
          PopupMenuButton<VoidCallback>(
            itemBuilder: (context) => [
              if (meal.youtubeLink != null)
                PopupMenuItem(
                  value: () {
                    launch(meal.youtubeLink);
                  },
                  child: const Text('Open in Youtube'),
                ),
              PopupMenuItem(
                value: () {
                  Share.share(
                      'Checkout this recipe...\n${meal.name}\n${meal.mealDbMealLink}');
                },
                child: Row(
                  children: <Widget>[
                    const Expanded(child: Text('Share')),
                    Icon(
                      Icons.share,
                      color: Theme.of(context).iconTheme.color.withOpacity(.6),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (callback) => callback(),
          ),
        ],
      ),
      body: _CookbookScreen(meal: meal),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    Key key,
    @required this.meal,
  })  : assert(meal != null),
        super(key: key);

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<Prefs>();
    final isFavorite = meal != null && prefs.isFavorite(meal.id);

    return IconButton(
      onPressed: () {
        final scaffold = Scaffold.of(context)..hideCurrentSnackBar();
        if (isFavorite) {
          prefs.removeFavorite(meal.id);
          scaffold.showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        } else {
          prefs.addFavorite(meal.id);
          scaffold.showSnackBar(
            const SnackBar(content: Text('Added to favorites')),
          );
        }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
        ),
      ),
      color: isFavorite ? Colors.pink.shade200 : null,
    );
  }
}

class _CookbookScreen extends StatelessWidget {
  const _CookbookScreen({
    Key key,
    @required this.meal, // nullable
  }) : super(key: key);
  final Meal meal;

  @override
  Widget build(context) {
    final loading = meal == null;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: padding16,
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: borderRadius8,
                child: CachedImage(
                  imageUrl: meal?.thumb,
                  placeholder: const LoadingShimmer(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading)
              ..._loading()
            else ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  meal.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline3.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 16),
              _IngredientsTable(ingredients: meal.ingredients),
              const SizedBox(height: 16),
              Text(
                'Lets Cook',
                style: theme.textTheme.headline6,
              ),
              const SizedBox(height: 16),
              Text(
                meal.instructions,
              ),
              if (meal.youtubeLink != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: borderRadius8,
                  child: _YoutubePlayer(meal: meal),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _loading() {
    return const [
      AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: LoadingShimmer(
          child: Block(
            widthFactor: .9,
            height: 24,
          ),
        ),
      ),
      SizedBox(height: 32),
      LoadingShimmer(
        child: Block(
          height: 16,
          widthFactor: .9,
          alignment: Alignment.centerRight,
        ),
      ),
      SizedBox(height: 16),
      LoadingShimmer(
        child: Block(
          height: 16,
          widthFactor: .6,
          alignment: Alignment.centerLeft,
        ),
      ),
    ];
  }
}

class _YoutubePlayer extends HookWidget {
  const _YoutubePlayer({
    Key key,
    @required this.meal,
  })  : assert(meal != null),
        super(key: key);

  final Meal meal;

  YoutubePlayerController createController(IsMounted isMounted) {
    final controller = YoutubePlayerController(
      initialVideoId: YoutubePlayerController.convertUrlToId(
        meal.youtubeLink,
      ),
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showVideoAnnotations: false,
      ),
    );
    controller
      ..onEnterFullscreen = enterFullscreen
      ..onExitFullscreen = () {
        exitFullscreen();
        if (controller.value.playerState == PlayerState.playing) {
          // Fix: video paused after exiting fullscreen
          Future<void>.delayed(const Duration(seconds: 1), () {
            if (isMounted()) controller.play();
          });
        }
      };

    return controller;
  }

  void enterFullscreen() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(const []);
  }

  void exitFullscreen() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    final _ytController = useState<YoutubePlayerController>();
    final isMounted = useIsMounted();
    final rebuild = useRebuild();

    useEffect(() => _ytController.value?.close, const []);

    final started = _ytController.value != null;
    final hasPlayed = started && _ytController.value.value.hasPlayed;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (started) YoutubePlayerIFrame(controller: _ytController.value),
          if (!hasPlayed) ...[
            CachedImage(
              imageUrl: meal.thumb,
              fit: BoxFit.cover,
            ),
            GestureDetector(
              onTap: () {
                // ignore: close_sinks, data may be added after close
                final controller = createController(isMounted);
                controller.asBroadcastStream()
                  ..first.then((_) {
                    controller
                      ..hideTopMenu()
                      ..play();
                  }).catchError((Object _) {})
                  ..firstWhere((value) => value.hasPlayed).then((_) {
                    rebuild();
                  }).catchError((Object _) {});

                _ytController.value = controller;
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Color(0xddffffff),
                ),
                child: started
                    ? const CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      )
                    : const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IngredientsTable extends HookWidget {
  const _IngredientsTable({
    Key key,
    @required this.ingredients,
  })  : assert(ingredients != null),
        super(key: key);

  final List<Ingredient> ingredients;

  Widget cell(Widget child) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: padding8,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headStyle = theme.accentTextTheme.subtitle1;
    final alternateDecoration = BoxDecoration(color: theme.primaryColorLight);
    return ClipRRect(
      borderRadius: borderRadius8,
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: theme.accentColor),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                child: Text('Ingredients', style: headStyle),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: Text('Measures', style: headStyle),
              ),
            ],
          ),
          for (int i = 0; i < ingredients.length; i++)
            TableRow(
              decoration: i.isEven ? null : alternateDecoration,
              children: [
                cell(
                  Row(
                    children: <Widget>[
                      SizedBox(
                          width: 32,
                          height: 32,
                          child: CachedImage(imageUrl: ingredients[i].thumb)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ingredients[i].name)),
                    ],
                  ),
                ),
                cell(
                  Text(ingredients[i].measure),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
