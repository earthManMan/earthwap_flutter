import 'package:firebase_login/domain/auth/datasource/auth_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepository(this._authDataSource);

  Future<UserCredential?> checkSMScode(
      String verification, String smsCode) async {
    return _authDataSource.checkSMSCode(verification, smsCode);
  }

  Future<void> sendSMSCode(
      String phoneNumber, Function(String, int?) callback) async {
    _authDataSource.verifyPhoneNumber(phoneNumber, callback);
  }

  Future<bool> register(String uid, String phone, String device_token) async {
    return _authDataSource.registerUserWithPhone(uid, phone, device_token);
  }

  Future<bool> deletePhoneAuth(String uid, String phone) async {
    return _authDataSource.deleteUserFromPhnoeAuth(uid, phone);
  }

  Future<String> loginwithPhone(String uid, String phone) async {
    return _authDataSource.loginwithPhone(uid, phone);
  }

  Future<UserCredential?> loginWithToken(String token) async {
    return _authDataSource.loginWithToken(token);
  }

  Future<void> logout() async {
    _authDataSource.logout();
  }
}
