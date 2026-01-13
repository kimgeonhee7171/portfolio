import 'package:shared_preferences/shared_preferences.dart';

/// 데이터 저장소 서비스
/// 로컬 데이터 저장 및 관리
class DataStorageService {
  static final DataStorageService instance = DataStorageService._internal();
  DataStorageService._internal();

  SharedPreferences? _prefs;

  /// SharedPreferences 인스턴스
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('DataStorageService가 초기화되지 않았습니다.');
    }
    return _prefs!;
  }

  /// 서비스 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 문자열 저장
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 문자열 가져오기
  String? getString(String key) {
    return prefs.getString(key);
  }

  /// 정수 저장
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 정수 가져오기
  int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// 불린 저장
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 불린 가져오기
  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// 키 삭제
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 모든 키 삭제
  Future<bool> clear() async {
    return await prefs.clear();
  }
}
