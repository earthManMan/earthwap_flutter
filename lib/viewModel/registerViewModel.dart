import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/registerModel.dart';
import 'package:firebase_login/service/alarmService.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterModel _model;

  RegisterViewModel(this._model);

  RegisterModel get model => _model;

  factory RegisterViewModel.initialize() {
    final registerModel = RegisterModel();

    return RegisterViewModel(registerModel);
  }

  bool isValid_uni() {
    if (_model.university.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  // University Setter
  void setUniversity(String university) {
    _model.university = university;
    notifyListeners();
  }

  // Domain Setter
  void setDomain(String domain) {
    _model.domain = domain;
    notifyListeners();
  }

  // Email Setter
  void setEmail(String email) {
    _model.email = email;
    notifyListeners();
  }

  // Password Setter
  void setPassword(String password) {
    _model.password = password;
    notifyListeners();
  }

  // Password Confirmation Setter
  void setPasswordConfirm(String passwordConfirm) {
    _model.passwordConfirm = passwordConfirm;
    notifyListeners();
  }

  // Auth Key Setter
  void setAuthKey(String authKey) {
    _model.authKey = authKey;
    notifyListeners();
  }

  // Auth Key Confirmation Setter
  void setAuthKeyConfirm(String authKeyConfirm) {
    _model.authKeyConfirm = authKeyConfirm;
    notifyListeners();
  }

  // Auth Code Setter
  void setAuthCode(bool authCode) {
    _model.authCode = authCode;
    notifyListeners();
  }

  // Auth Key Confirmation Setter
  void setphoneNumber(String number) {
    _model.phone = number;
    notifyListeners();
  }

  Future<bool> isValidDomain(String domain) async {
    final api = FirebaseAPI();

    final result = await api.verifyUniversityDomainOnCallFunction(domain);
    if (result) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getUniversityList() async {
    final api = FirebaseAPI();

    final result = await api.getAllUniversitiesOnCallFunction();
    if (result.isNotEmpty) {
      _model.universityList = result;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> EmailSendButtonPressed() async {
    final api = FirebaseAPI();

    final result = await api.sendEmailVerification(_model.email.toString());
    if (result.isNotEmpty) {
      _model.authKey = result;
      return true;
    } else {
      return false;
    }
  }

  Future<void> PhoneCodeSendButtonPressed() async {
    _model.verificationId = "";
    final api = FirebaseAPI();
    await api.verifyPhoneNumber(
      _model.phone.toString(),
      (p0, p1) {
        _model.verificationId = p0.toString();
      },
    );
  }

  Future<bool> signInWithSMSCode(String sms) async {
    final api = FirebaseAPI();

    final result =
        await api.checkSMSCode(_model.verificationId, sms.toString());
    if (result != null) {
      _model.uid = result.user!.uid;
      print(result.user!.uid);
      return true;
    } else {
      return false;
    }
  }

  Future<RegistrationStatus> registerUser() async {
    final api = FirebaseAPI();
    final alarm = AlarmService.instance;

    // 현재 로그인 된 Auth Logout
    await api.logout();
    // 계정 생성 후 삭제
      final result = await api.registerUserWithPhone(
          _model.uid, _model.phone, alarm.fcmToken.toString());
    if (result) {
      final delete = await api.deleteUserFromPhnoeAuth(_model.uid, _model.phone);
      if (delete)
      {
        print("계정 생성 성공!");
        return RegistrationStatus.success;
      }else{
        print("계정 삭제 실패!");
        return RegistrationStatus.deleted;
      }
    } else {
      print("계정 생성 실패!");
        return RegistrationStatus.registered;
    }
  }

  void clearModel() {
    model.clearModel();
  }
}
