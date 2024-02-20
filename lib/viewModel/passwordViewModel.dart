import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/passwordModel.dart';

class PasswordViewModel extends ChangeNotifier {
  final PasswordModel _model;

  PasswordViewModel(this._model);

  PasswordModel get model => _model;

  factory PasswordViewModel.initialize() {
    final Model = PasswordModel();

    return PasswordViewModel(Model);
  }

  Future<bool> SendEmail() async {
    final api = FirebaseAPI();

    final result =
        api.sendEmailOnCallFunction(EmailType.ChangePassword, model.email);
    if (result.toString().isNotEmpty) {
      _model.authKey = result.toString();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resetPassword() async {
    final api = FirebaseAPI();

    final result = api.resetPassword(model.email);
    if (result.toString().isNotEmpty) {
      _model.authKey = result.toString();
      return true;
    } else {
      return false;
    }
  }

  void clearModel() {
    _model.clearmodel();
  }
}
