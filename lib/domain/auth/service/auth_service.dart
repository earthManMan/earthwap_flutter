import 'package:firebase_login/domain/auth/model/auth_model.dart';
import 'package:firebase_login/domain/auth/repo/auth_repository.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthModel _authModel;

  AuthService(this._authRepository, this._authModel);

  AuthModel get authModel => _authModel;

  set authModel(AuthModel authModel) {
    _authModel = authModel;
  }

  Future<UserCredential?> checkSMScode() async {
    return _authRepository.checkSMScode(
        _authModel.verificationId, _authModel.smsCode);
  }

  Future<void> sendSMSCode(Function(String, int?) callback) async {
    _authRepository.sendSMSCode(_authModel.phone, callback);
  }

  Future<bool> register() async {
    return _authRepository.register(
        _authModel.phone_uid, _authModel.phone, _authModel.device_token);
  }

  Future<bool> deletePhoneAuth() async {
    return _authRepository.deletePhoneAuth(_authModel.phone_uid, _authModel.phone);
  }

  Future<void> logout() async {
    _authRepository.logout();
  }

  Future<String> createToken() async {
    return _authRepository.loginwithPhone(_authModel.phone_uid, _authModel.phone);
  }

  Future<UserCredential?> login() async {
    return _authRepository.loginWithToken(_authModel.token);
  }

  void clearModel() {
    _authModel = AuthModel();
  }
}
