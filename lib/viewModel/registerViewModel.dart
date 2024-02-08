import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/registerModel.dart';

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

  Future<bool> registerUser() async {
    final api = FirebaseAPI();

    final result = await api.registerUserOnCallFunction(
        _model.email, _model.password, _model.authCode, _model.university);
    return result;
  }

  void clearModel() {
    model.clearModel();
  }
}
