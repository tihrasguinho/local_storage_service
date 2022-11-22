import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

class PreferencesService implements LocalStorageService {
  static Completer<PreferencesService>? _completer;

  static SharedPreferences? _prefs;

  PreferencesService._();

  static Future<PreferencesService> instance() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      _completer ??= Completer<PreferencesService>();
      _completer!.complete(PreferencesService._());
      return _completer!.future;
    } on Exception catch (e) {
      _completer!.completeError(e);
      final future = _completer!.future;
      return future;
    }
  }

  @override
  bool exists(String key) {
    return _prefs!.containsKey(key);
  }

  @override
  T? get<T>(String key) {
    if (!exists(key)) throw Exception('Key [$T] not found!');

    switch (T) {
      case String:
        return _prefs!.getString(key) as T;
      case int:
        return _prefs!.getInt(key) as T;
      case double:
        return _prefs!.getDouble(key) as T;
      case bool:
        return _prefs!.getBool(key) as T;
      case List<String>:
        return _prefs!.getStringList(key) as T;
      case ProspectEntity:
        final source = _prefs!.getString(key);
        return ProspectDto.fromJson(source!) as T;
      case List<ProspectEntity>:
        final list = _prefs!.getStringList(key);
        return list?.map((e) => ProspectDto.fromJson(e)).toList() as T;
      case Map:
      case Map<String, dynamic>:
      case Map<String, String>:
        final list = _prefs!.getStringList(key);
        final handler = {};
        for (final item in list ?? <String>[]) {
          final splitted = item.split('/');
          final k = splitted[0];
          final v = jsonDecode(splitted.sublist(1).join('/'));
          handler[k] = v;
        }
        return handler as T;
      default:
        throw Exception('Type $T not allowed!');
    }
  }

  @override
  Future<T?> put<T>(String key, T value) async {
    switch (T) {
      case String:
        await _prefs!.setString(key, value as String);
        return value;
      case int:
        await _prefs!.setInt(key, value as int);
        return value;
      case double:
        await _prefs!.setDouble(key, value as double);
        return value;
      case bool:
        await _prefs!.setBool(key, value as bool);
        return value;
      case List<String>:
        await _prefs!.setStringList(key, value as List<String>);
        return value;
      case ProspectEntity:
        final source = (value as ProspectEntity).toJson();
        await _prefs!.setString(key, source);
        return value;
      case List<ProspectEntity>:
        final list = (value as List<ProspectEntity>).map((e) => e.toJson()).toList();
        await _prefs!.setStringList(key, list);
        return value;
      case Map:
      case Map<String, dynamic>:
      case Map<String, String>:
        final map = value as Map;
        final handler = <String>[];
        for (final k in map.keys) {
          final data = jsonEncode(map[k], toEncodable: _toEncodable);
          handler.add('$k/$data');
        }
        await _prefs!.setStringList(key, handler);
        return value;
      default:
        throw Exception('Type ${value.runtimeType} not allowed!');
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs!.remove(key);
    return;
  }

  Object? _toEncodable(Object? object) {
    if (object is DateTime) {
      return object.toIso8601String();
    } else if (object is ProspectEntity) {
      return object.toJson();
    } else {
      return object;
    }
  }
}
