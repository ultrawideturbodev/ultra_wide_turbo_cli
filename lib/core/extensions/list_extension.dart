extension ListExtensionExtension<T> on List<T> {
  Map<E, T> toIdMap<E extends Object>(E Function(T element) id) {
    final map = <E, T>{};
    for (final element in this) {
      map[id(element)] = element;
    }
    return map;
  }
}
