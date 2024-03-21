import 'package:flutter/material.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:firebase_login/domain/auth/service/auth_service.dart';
import 'dart:async';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  RegisterViewModel(this._authService);

  Future<bool> sendPhoneCode(String number) async {
    Completer<bool> completer = Completer<bool>();

    _authService.authModel.verificationId = "";
    _authService.authModel.phone = number;

    await _authService.sendSMSCode((p0, p1) {
      if (p0.isNotEmpty) {
        _authService.authModel.verificationId = p0.toString();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  Future<bool> verifySMSCode(String sms) async {
    _authService.authModel.smsCode = sms;
    final result = await _authService.checkSMScode();
    if (result != null) {
      _authService.authModel.phone_uid = result.user!.uid;
      return true;
    } else {
      return false;
    }
  }

  Future<RegistrationStatus> registerUser() async {
    try {
      // 현재 로그인 된 Auth Logout
      await _authService.logout();
      // 계정 생성 후 삭제
      final alarm = AlarmService.instance;
      _authService.authModel.device_token = alarm.fcmToken.toString();
      final result = await _authService.register();

      if (result) {
        final delete = await _authService.deletePhoneAuth();
        if (delete) {
          print("계정 생성 성공!");
          return RegistrationStatus.success;
        } else {
          print("계정 삭제 실패!");
          return RegistrationStatus.deleted;
        }
      } else {
        final delete = await _authService.deletePhoneAuth();
        if (!delete) {
          print("계정 삭제 실패!");
          return RegistrationStatus.deleted;
        }
        print("계정 생성 실패!");
        return RegistrationStatus.registered;
      }
    } catch (e) {
      print("Error during user registration: $e");
      return RegistrationStatus.error;
    }
  }
}
