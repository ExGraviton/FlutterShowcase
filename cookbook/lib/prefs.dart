import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shared_preferences/shared_preferences.dart';

class Prefs extends ChangeNotifier {
  Prefs(this._prefs) : assert(_prefs != null);
  final SharedPreferences _prefs;

  static const _isDarkKey = 'isDark';
  bool get isDark => _prefs.getBool(_isDarkKey) ?? false;
  set isDark(bool value) {
    _prefs.setBool(_isDarkKey, value);
    notifyListeners();
  }

  // This state is not persisted
  bool _slowMotion = false;
  bool get slowMotion => _slowMotion;
  set slowMotion(bool value) {
    _slowMotion = value;
    timeDilation = slowMotion ? 5 : 1;
    notifyListeners();
  }

  static const _favoritesKey = 'favorites';

  List<String> get favorites => _prefs.getStringList(_favoritesKey) ?? [];

  bool isFavorite(String id) => favorites.contains(id);

  void addFavorite(String id) {
    _prefs.setStringList(_favoritesKey, [id, ...favorites]);
    notifyListeners();
  }

  void removeFavorite(String id) {
    _prefs.setStringList(_favoritesKey, favorites..remove(id));
    notifyListeners();
  }
}
