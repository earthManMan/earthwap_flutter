import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/app/util/localStorage_util.dart';
import 'package:firebase_login/domain/auth/service/auth_service.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'dart:async';

class LoginViewModel extends ChangeNotifier {
  final UserService _userService;
  final AuthService _authService;
  final _storage = LocalStorage();

  LoginViewModel(
    this._userService,
    this._authService,
  );

  Future<void> saveAutoLogin(bool state) async {
    await _storage.saveitem(KEY_AUTOLOGIN, state.toString());
  }

  Future<void> saveLoginToken(String token) async {
    await _storage.saveitem(KEY_TOKEN, token);
  }

  Future<bool> checkAutoLogin() async {
    final auto = await _storage.getitem(KEY_AUTOLOGIN);
    if (auto.toString() == "true") {
      final token = await _storage.getitem(KEY_TOKEN);
      if (token.toString().isNotEmpty) {
        _authService.authModel.token = token.toString();
        return true;
      } else
        return false;
    } else
      return false;
  }

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

  Future<LoginStatus> AutoPhonelogin(BuildContext context) async {
    final alarm = AlarmService.instance;
    final api = FirebaseAPI();
    final token = await _storage.getitem(KEY_TOKEN);

    if (token.toString().isNotEmpty) {
      _authService.authModel.token = token.toString();

      await _authService.logout();

      final userinfo = await _authService.login();
      if (userinfo!.user!.uid.isEmpty) {
        _authService.authModel.token = "";
        await _storage.deleteitem(KEY_TOKEN);
        return LoginStatus.logined;
      }

      _authService.authModel.uid = userinfo!.user!.uid.toString();

      final myPageViewModel =
          Provider.of<MypageViewModel>(context, listen: false);

      _userService.startListeningToUserDataChanges(_authService.authModel.uid);
      alarm.startListeningToNotifications(_authService.authModel.uid);
      myPageViewModel.startListeningToFollowers(_authService.authModel.uid);
      myPageViewModel.startListeningToFollowing(_authService.authModel.uid);

      return LoginStatus.success;
    } else {
      await _storage.deleteitem(KEY_TOKEN);
      return LoginStatus.logined;
    }
  }

  Future<LoginStatus> Phonelogin(BuildContext context) async {
    final alarm = AlarmService.instance;
    final api = FirebaseAPI();
    // Phone Auth Logout
    await _authService.logout();

    // Token 발행 성공 및 실패 모두 PhoneAuth 제거 필요.
    final token = await _authService.createToken();
    if (token.isNotEmpty) {
      _authService.authModel.token = token.toString();
      final delete = await _authService.deletePhoneAuth();
      if (!delete) {
        return LoginStatus.deleted;
      }
    } else {
      final delete = await _authService.deletePhoneAuth();
      if (!delete) {
        return LoginStatus.deleted;
      }
      return LoginStatus.cretedtoken;
    }

    // local token 저장
    saveLoginToken(token);

    final userinfo = await _authService.login();
    if (userinfo!.user!.uid.isEmpty) {
      return LoginStatus.logined;
    }

    _authService.authModel.uid = userinfo.user!.uid.toString();

    final myPageViewModel =
        Provider.of<MypageViewModel>(context, listen: false);

    final result = await _userService
        .startListeningToUserDataChanges(_authService.authModel.uid);
    if (result) {
      alarm.startListeningToNotifications(_authService.authModel.uid);
      myPageViewModel.startListeningToFollowers(_authService.authModel.uid);
      myPageViewModel.startListeningToFollowing(_authService.authModel.uid);
    }

    return LoginStatus.success;
  }
}
