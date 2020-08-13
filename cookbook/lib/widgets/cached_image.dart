import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../cache_manager.dart';

final _cache = CacheManager('image_cache');

class CachedImage extends StatefulWidget {
  const CachedImage({
    Key key,
    @required this.imageUrl, // if null displays placeholder
    this.placeholder = const SizedBox(),
    this.fadeDuration = const Duration(milliseconds: 500),
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
  })  : assert(alignment != null),
        assert(placeholder != null),
        assert(fadeDuration != null),
        assert(filterQuality != null),
        super(key: key);

  final String imageUrl;
  final Widget placeholder;
  final Duration fadeDuration;
  final Color color;
  final BlendMode colorBlendMode;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  _CachedImageState createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  CachedImageProvider provider;
  bool loading = true;

  @override
  void didChangeDependencies() {
    updateImageProvider(widget.imageUrl);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    updateImageProvider(widget.imageUrl);
    super.didUpdateWidget(oldWidget);
  }

  void updateImageProvider(String url) {
    if (url == null) {
      loading = true;
      provider = null;
      return;
    }

    if (url != provider?.imageUrl) {
      provider = CachedImageProvider(url);

      if (imageCache.statusForKey(provider.key).keepAlive) {
        loading = false;
      } else {
        loading = true;
        precacheImage(provider, context).then((value) {
          if (mounted) {
            setState(() => loading = false);
          }
        });
      }
    }
  }

  @override
  Widget build(context) {
    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [...previousChildren, if (currentChild != null) currentChild],
      ),
      child: loading
          ? widget.placeholder
          : Image(
              image: provider,
              color: widget.color,
              colorBlendMode: widget.colorBlendMode,
              fit: widget.fit,
              alignment: widget.alignment,
              filterQuality: widget.filterQuality,
            ),
    );
  }
}

class CachedImageProvider extends ImageProvider<String> {
  const CachedImageProvider(this.imageUrl) : assert(imageUrl != null);

  final String imageUrl;

  @override
  ImageStreamCompleter load(String key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(codec: _load(decode), scale: 1);
  }

  Future<ui.Codec> _load(DecoderCallback decode) async {
    final file = await _cache.getSingleFile(imageUrl);
    final data = await file.readAsBytes();
    return decode(data);
  }

  @override
  Future<String> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(key);
  }

  String get key => imageUrl;
}
