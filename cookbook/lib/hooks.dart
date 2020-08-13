import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

VoidCallback useRebuild() {
  return (useContext() as Element).markNeedsBuild;
}

AsyncSnapshot<T> useMemoizedFuture<T>(Future<T> Function() valueBuilder,
    [List<Object> keys = const <dynamic>[]]) {
  final memo = useMemoized(valueBuilder, keys);
  return useFuture(memo);
}
