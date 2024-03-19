import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String tokenkey = 'token';

class LocalStorage {
  final storage = const FlutterSecureStorage();

  // TODO : logout 시 유효한 토큰 값 제거 하기
  Future<void> delete_token() async {
    await storage.delete(key: tokenkey);
  }

  // TODO : 자동 로그인 시 해당 토큰 가져오기
  Future<String?> get_token() async {
    final token = await storage.read(key: tokenkey);

    if (token != null) {
      return token;
    } else {
      return null;
    }
  }

  // 자동 로그인 체크 후 로그인 시 토큰 저장하기
  Future<void> save_token(String token) async {
    await storage.write(key: tokenkey, value: token);
  }
}
