import 'package:turbo_response/turbo_response.dart';

typedef AddDef<T> = Future<TurboResponse> Function({required T item});
typedef RemoveDef<T> = Future<TurboResponse> Function({required T item});
typedef ClearDef = Future<TurboResponse> Function();
