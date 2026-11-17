/// Shared deep-cast utilities converting Hive's untyped `Map<dynamic, dynamic>`
/// and `List<dynamic>` structures into `Map<String, dynamic>` for `fromJson`.
Map<String, dynamic> deepCastMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), deepCastMap(value));
    }
    if (value is List) {
      return MapEntry(key.toString(), deepCastList(value));
    }
    return MapEntry(key.toString(), value);
  });
}

/// Recursively normalizes nested maps inside a [List] returned from Hive.
List<dynamic> deepCastList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) return deepCastMap(item);
    if (item is List) return deepCastList(item);
    return item;
  }).toList();
}
