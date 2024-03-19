import 'package:encrypt/encrypt.dart' as enc;

class StringEncryptor {
  // TODO: 나중에 Key는 변경
  static const String AES_Key = "abcdefghijtuvwxyz1234klmnopqrs56";
  static final key = enc.Key.fromUtf8(AES_Key);
  static final iv = enc.IV.fromBase64("w96q91bljIm5XBhTykQo5A==");

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  StringEncryptor._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final StringEncryptor _instance =
      StringEncryptor._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static StringEncryptor get instance => _instance;

  String AES_encrypt(String value) {
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(value, iv: iv);
    print(encrypted.base64);
    return encrypted.base64;
  }

  String AES_decrypt(String encrypted) {
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    enc.Encrypted enBase64 = enc.Encrypted.fromBase64(encrypted);
    final decrypted = encrypter.decrypt(enBase64, iv: iv);
    return decrypted;
  }
}
