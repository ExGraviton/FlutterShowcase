import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheManager extends BaseCacheManager {
  CacheManager(
    this.key, {
    int maxCache = 1000,
    Duration maxAge = const Duration(days: 30),
    this.maxRetry = 10,
    this.retryDelay = const Duration(seconds: 30),
  })  : assert(key != null),
        assert(maxRetry >= 0),
        assert(retryDelay != null && retryDelay > Duration.zero),
        _path = _tempDir.then((dir) => p.join(dir.path, key)),
        super(key, maxAgeCacheObject: maxAge, maxNrOfCacheObjects: maxCache);

  final String key;
  final int maxRetry;
  final Duration retryDelay;

  static final _tempDir = getTemporaryDirectory();
  final Future<String> _path;
  @override
  Future<String> getFilePath() => _path;

  @override
  Future<FileInfo> downloadFile(url, {authHeaders, force = false}) async {
    var retry = 0;
    // ignore: literal_only_boolean_expressions
    while (true) {
      try {
        return await super
            .downloadFile(url, authHeaders: authHeaders, force: force);
      } catch (e) {
        if (retry == maxRetry) {
          rethrow;
        }
        retry++;
        await Future<void>.delayed(retryDelay);
      }
    }
  }
}
