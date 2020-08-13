import 'package:flutter/widgets.dart';

const padding8 = EdgeInsets.all(8);
const padding16 = EdgeInsets.all(16);

const borderRadius8 = BorderRadius.all(Radius.circular(8));
const borderRadius16 = BorderRadius.all(Radius.circular(16));

const shapeBorder8 = RoundedRectangleBorder(borderRadius: borderRadius8);
const shapeBorder16 = RoundedRectangleBorder(borderRadius: borderRadius16);

class Assets {
  Assets._();

  static const iconImage = AssetImage('images/icon.webp');
  static const drawerImage = AssetImage('images/drawer.webp');
}
