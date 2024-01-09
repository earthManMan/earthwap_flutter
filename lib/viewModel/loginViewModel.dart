import 'package:firebase_login/service/alarmService.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/view/mypage/mypageView.dart';
import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:firebase_login/viewModel/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/loginModel.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_login/components/Encryptoring.dart'; // Replace with the actual file path where you put the StringEncryptor class
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_login/viewModel/homeViewModel.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginModel _model;
  final UserService _userService;

  LoginModel get model => _model;

// Auto Login 설정
  bool get autoLogin => model.autoLogin;

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory LoginViewModel.initialize(UserService service) {
    final loginModel = LoginModel(); // 필요한 초기화 로직을 수행하도록 변경
    return LoginViewModel(
      loginModel,
      service,
    );
  }

  LoginViewModel(
    this._model,
    this._userService,
  );

  set autoLogin(bool value) {
    model.autoLogin = value;
    notifyListeners();
  }

  // Email 저장 설정
  bool get rememberEmail => model.rememberEmail;
  set rememberEmail(bool value) {
    model.rememberEmail = value;
    notifyListeners();
  }

  // Auto Login 설정 업데이트 함수
  void updateAutoLogin(bool autoLogin) {
    model.autoLogin = autoLogin;
    notifyListeners();
  }

  // Remember Email 설정 업데이트 함수
  void updateRememberEmail(bool rememberEmail) {
    model.rememberEmail = rememberEmail;

    notifyListeners();
  }

  Future<void> saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_model.autoLogin == true) {
      await prefs.setString('email', _model.email);
      await prefs.setString('password', _model.password);
    } else if (_model.rememberEmail == true) {
      await prefs.setString('email', _model.email);
    } else {
      await prefs.setString('email', "");
      await prefs.setString('password', "");
    }
  }

  Future<void> getLoginInfo() async {
    StringEncryptor encryptor = StringEncryptor.instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final password = prefs.getString('password') ?? '';

    _model.email = email;
    _model.password = password;
    if (email.isNotEmpty) {
      _model.rememberEmail = true;
    }
    if (password.isNotEmpty) {
      _model.autoLogin = true;
    }
    notifyListeners();
  }

  // 이메일 설정 메서드
  void setEmail(String email) {
    _model.email = email;
  }

  // 비밀번호 설정 메서드
  void setPassword(String password) {
    _model.password = password;
  }

  Future<void> logout(BuildContext context) async {
    try {
      final api = FirebaseAPI();
      await api.logout();
    } catch (e) {
      print(e);
    }
  }

  Future<bool> login(BuildContext context) async {
    saveLoginInfo();

    final api = FirebaseAPI();
    final user = await api.loginWithEmail(_model.email, _model.password);

    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sellViewModel = Provider.of<SellViewModel>(context, listen: false);
    final myPageViewModel =
        Provider.of<MypageViewModel>(context, listen: false);

    homeViewModel.categorymodel.clearcategories();
    sellViewModel.categorymodel.clearcategories();
    myPageViewModel.categorymodel.clearcategories();

    api.getAllCategoriesOnCallFunction().then((value) => {
          for (final item in value)
            {
              homeViewModel.categorymodel.addcategory(item['id'].toString()),
              sellViewModel.categorymodel.addcategory(item['id'].toString()),
              myPageViewModel.categorymodel.addcategory(item['id'].toString()),
            }
        });

    String uid = user!.user!.uid.toString();
    final alarm = AlarmService.instance;

    await api
        .addDeviceTokenOnCallFunction(uid, alarm.fcmToken.toString())
        .then((value) => {
              _userService.startListeningToUserDataChanges(uid),
              alarm.startListeningToNotifications(uid),
              myPageViewModel.startListeningToFollowers(uid),
              myPageViewModel.startListeningToFollowing(uid),
            });

    return true;
  }

  void clearModel() {
    _model.claerModel();
  }
}
