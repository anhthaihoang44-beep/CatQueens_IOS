import 'package:hive_flutter/hive_flutter.dart';
import 'storage_service.dart';

class HiveStorageService implements StorageService {
  final Map<String, Box> _openBoxes = {};
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      if (!Hive.isBoxOpen('catqueens_progress')) {
        final box = await Hive.openBox('catqueens_progress');
        _openBoxes['catqueens_progress'] = box;
      }
    } catch (_) {
      // In headless unit tests where path_provider is not available
    }
    _initialized = true;
  }

  Future<Box?> _getBox(String boxName) async {
    if (!_initialized) await init();
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName]!;
    }
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        _openBoxes[boxName] = box;
        return box;
      }
      final box = await Hive.openBox(boxName);
      _openBoxes[boxName] = box;
      return box;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> set<T>(String box, String key, T value) async {
    final b = await _getBox(box);
    await b?.put(key, value);
  }

  @override
  T? get<T>(String box, String key, [T? defaultValue]) {
    Box? b = _openBoxes[box];
    if (b == null) {
      try {
        if (Hive.isBoxOpen(box)) {
          b = Hive.box(box);
          _openBoxes[box] = b;
        }
      } catch (_) {}
    }
    if (b == null) return defaultValue;
    final val = b.get(key, defaultValue: defaultValue);
    if (val is T) return val;
    return defaultValue;
  }

  @override
  Future<void> remove(String box, String key) async {
    final b = await _getBox(box);
    await b?.delete(key);
  }

  @override
  Future<void> clear(String box) async {
    final b = await _getBox(box);
    await b?.clear();
  }
}
