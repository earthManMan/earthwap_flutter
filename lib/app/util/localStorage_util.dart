import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String tokenkey = 'token';
const String autologinkey = 'autologin';

class LocalStorage {
  final storage = const FlutterSecureStorage();

  Future<void> deleteitem(String key) async {
    await storage.delete(key: key);
  }

  Future<String?> getitem(String key) async {
    final item = await storage.read(key: key);

    if (item != null) {
      return item;
    } else {
      return "";
    }
  }

  Future<void> saveitem(String key, String value) async {
    await storage.write(key: key, value: value);
  }
}
