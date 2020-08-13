import 'dart:convert';

import 'cache_manager.dart';

final _cacheManager = CacheManager('meals_db_cache');

class MealDB {
  MealDB() {
    category = _get(_categories).then((source) {
      final data = json.decode(source) as Map<String, Object>;
      return (data['categories'] as List)
          .map((Object e) => Category.fromMap(e as Map<String, Object>))
          .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    });
    randoms = Future.wait(Iterable.generate(4, (index) => getRandomMeal()));
  }

  Future<List<Meal>> randoms;

  static String _getKey() => '1';

  static final _api = 'https://www.themealdb.com/api/json/v1/${_getKey()}/';
  static final _categories = '${_api}categories.php';
  static final _mealsByCategory = '${_api}filter.php?c=';
  static final _mealById = '${_api}lookup.php?i=';
  static final _randomMeal = '${_api}random.php';
  static final _searchByName = '${_api}search.php?s=';

  Future<String> _get(String url, {bool cache = true}) {
    if (cache) {
      return _cacheManager
          .getSingleFile(url)
          .then((value) => value.readAsString());
    } else {
      return _cacheManager
          .downloadFile(url)
          .then((value) => value.file.readAsString());
    }
  }

  final _mealShortsCache = <String, Future<List<MealShort>>>{};
  Future<List<MealShort>> getMealsFromCategory(String category) {
    return _mealShortsCache[category] ??=
        _get('$_mealsByCategory$category').then((source) {
      final data = json.decode(source) as Map<String, Object>;
      return (data['meals'] as List)
          .map((Object e) => MealShort.fromMap(e as Map<String, Object>))
          .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  final _mealCache = <String, Future<Meal>>{};
  Future<Meal> getMeal(String id) {
    return _mealCache[id] ??= _get('$_mealById$id').then((source) {
      final data = json.decode(source) as Map<String, Object>;
      return Meal.fromMap((data['meals'] as List)[0] as Map<String, Object>);
    });
  }

  var _r = 0;
  Future<Meal> getRandomMeal() {
    return _get('$_randomMeal?${_r++}', cache: false).then((source) {
      final data = json.decode(source) as Map<String, Object>;
      final meal =
          Meal.fromMap((data['meals'] as List)[0] as Map<String, Object>);
      _mealCache[meal.id] = Future.value(meal);
      return meal;
    });
  }

  final _searchCache = <String, Future<List<MealShort>>>{};
  Future<List<MealShort>> search(String query) {
    return _searchCache[query] ??=
        _get('$_searchByName$query', cache: false).then((source) {
      final data = json.decode(source) as Map<String, Object>;
      return (data['meals'] as List) // maybe null
              ?.map((Object e) => MealShort.fromMap(e as Map<String, Object>))
              ?.toList() ??
          const [];
    });
  }

  Future<List<Category>> category;
}

class Category {
  Category({
    this.id,
    this.name,
    this.thumb,
    this.description,
  });

  factory Category.fromMap(Map<String, Object> map) {
    return Category(
      id: map['idCategory'] as String,
      name: map['strCategory'] as String,
      thumb: map['strCategoryThumb'] as String,
      description: map['strCategoryDescription'] as String,
    );
  }

  factory Category.fromJson(String source) {
    return Category.fromMap(json.decode(source) as Map<String, Object>);
  }

  final String id;
  final String name;
  final String thumb;
  final String description;
}

class MealShort {
  MealShort({
    this.id,
    this.name,
    this.thumb,
  });

  factory MealShort.fromMap(Map<String, dynamic> map) {
    return MealShort(
      id: map['idMeal'] as String,
      name: map['strMeal'] as String,
      thumb: map['strMealThumb'] as String,
    );
  }

  factory MealShort.fromJson(String source) =>
      MealShort.fromMap(json.decode(source) as Map<String, Object>);

  final String id;
  final String name;
  final String thumb;
  String get mealDbMealLink => 'https://www.themealdb.com/meal/$id';
}

class Ingredient {
  Ingredient(this.name, this.measure);

  final String name;
  final String measure;
  String get thumb =>
      'https://www.themealdb.com/images/ingredients/$name-small.png';
}

class Meal extends MealShort {
  Meal({
    String id,
    String name,
    String thumb,
    String instructions,
    this.ingredients,
    this.youtubeLink,
  })  : instructions = _prettifyInstructions(instructions),
        super(id: id, name: name, thumb: thumb);

  factory Meal.fromMap(Map<String, Object> map) {
    if (map == null) return null;

    const ingredient = 'strIngredient';
    const measure = 'strMeasure';

    final ingredients = [
      for (int i = 1; _isNotEmpty(map['$ingredient$i'] as String); i++)
        Ingredient(map['$ingredient$i'] as String, map['$measure$i'] as String)
    ];

    return Meal(
      id: map['idMeal'] as String,
      name: map['strMeal'] as String,
      ingredients: ingredients,
      instructions: map['strInstructions'] as String,
      thumb: map['strMealThumb'] as String,
      youtubeLink: _ifNotEmpty(map['strYoutube'] as String),
    );
  }

  factory Meal.fromJson(String source) =>
      Meal.fromMap(json.decode(source) as Map<String, Object>);

  static bool _isNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  static String _ifNotEmpty(String str) {
    return _isNotEmpty(str) ? str : null;
  }

  static final _numberLine = RegExp(r'^\d+\.?$', multiLine: true);
  static final _lineStart = RegExp('^', multiLine: true);
  static final _newLines = RegExp(r'\n{2,}');
  static String _prettifyInstructions(String instructions) {
    const indent = '    ';

    return instructions
        .replaceAll('\r\n', '\n') // CRLF to LF
        .replaceAll(_numberLine, '')
        .replaceAll(_newLines, '\n')
        .trim()
        .replaceAll(_lineStart, indent)
        .replaceAll('\n', '\n\n');
  }

  final String instructions;
  final String youtubeLink;
  final List<Ingredient> ingredients;
}
