import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

import '../constants.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer(
      {this.child = const ColoredBox(color: Colors.grey), Key key})
      : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const baseLight = Color(0xFFBDBDBD);
    const hlLight = Color(0xFFE0E0E0);

    const baseDark = Color(0xFF424242);
    const hlDark = Color(0xFF616161);

    const gradDark = LinearGradient(
      begin: Alignment.topLeft,
      colors: <Color>[baseDark, hlDark, hlDark, baseDark],
      stops: [0.35, 0.48, 0.5, 0.65],
    );
    const gradLight = LinearGradient(
        begin: Alignment.topLeft,
        colors: <Color>[baseLight, hlLight, hlLight, baseLight],
        stops: [0.35, 0.48, 0.5, 0.65]);

    return Shimmer(
      gradient: isDark ? gradDark : gradLight,
      child: child,
    );
  }
}

class Block extends StatelessWidget {
  const Block({
    Key key,
    this.width,
    this.height,
    this.widthFactor,
    this.heightFactor,
    this.alignment,
    this.padding,
    this.decoration = const ShapeDecoration(
      color: Colors.grey,
      shape: shapeBorder16,
    ),
  })  : assert(width == null || widthFactor == null),
        assert(height == null || heightFactor == null),
        super(key: key);
  final double widthFactor, heightFactor;
  final double width, height;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final Decoration decoration;

  @override
  Widget build(context) {
    Widget widget = Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      margin: padding,
      alignment: alignment,
      decoration: decoration,
    );
    if (widthFactor != null || heightFactor != null) {
      widget = FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: widget,
      );
    }
    return widget;
  }
}

/// Displays data if `data != null` or else [LoadingShimmer]
class TextOrBlock extends StatelessWidget {
  const TextOrBlock(
    this.data, {
    this.style,
    this.lines,
    this.overflow,
    Key key,
  }) : super(key: key);
  final String data;
  final TextStyle style;
  final int lines;
  final TextOverflow overflow;

  @override
  Widget build(context) {
    if (data != null) {
      return Text(
        data,
        style: style,
        maxLines: lines,
        overflow: overflow,
      );
    }
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textStyle = style ?? defaultTextStyle?.style;

    final fontSize = textStyle?.fontSize ?? 14;
    final blocks = lines ?? defaultTextStyle?.maxLines ?? 1;

    final padding = EdgeInsets.all(fontSize * .2);

    return LoadingShimmer(
      child: blocks == 1
          ? Block(
              padding: padding,
              widthFactor: .6,
              height: fontSize,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < blocks - 1; i++)
                  Block(
                    padding: padding,
                    height: fontSize * .8,
                  ),
                Block(
                  padding: padding,
                  widthFactor: .4,
                  height: fontSize * .8,
                )
              ],
            ),
    );
  }
}

class NoItemIndicator extends StatelessWidget {
  const NoItemIndicator({Key key, @required this.icon, @required this.text})
      : assert(icon != null),
        assert(text != null),
        super(key: key);

  final IconData icon;
  final String text;
  @override
  Widget build(context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.headline5
        .copyWith(color: theme.textTheme.headline5.color.withOpacity(.6));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 128,
            color: IconTheme.of(context).color.withOpacity(.2),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: textTheme,
          ),
        ],
      ),
    );
  }
}
