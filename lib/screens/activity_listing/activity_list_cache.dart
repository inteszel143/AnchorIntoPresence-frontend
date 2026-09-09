import 'getactivity_model.dart';

/// Session-only list cache. A revision prevents stale requests from repopulating it.
class ActivityListCache {
  static int _revision = 0;
  static final Map<String, ActivityResponse> _lists = {};

  static int get revision => _revision;
  static ActivityResponse? get(String key) => _lists[key];

  static void put(String key, ActivityResponse value, int revision) {
    if (revision != _revision) return;
    if (_lists.length >= 20) _lists.remove(_lists.keys.first);
    _lists[key] = value;
  }

  static void clear() {
    _revision++;
    _lists.clear();
  }
}
