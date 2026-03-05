/// Kotlin style `let` extension for nullable types in Dart.
///
/// Usage:
/// ```dart
/// // Before
/// final value = getNullableValue();
/// final result = value == null ? null : int.tryParse(value);
///
/// // After
/// final result = getNullableValue().let(int.tryParse);
/// ```
extension Let<T> on T? {
  R? let<R>(R? Function(T it) block) => this == null ? null : block(this as T);
}
