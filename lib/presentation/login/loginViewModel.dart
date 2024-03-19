import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/domain/login/login_model.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_login/presentation/components/Encryptoring.dart'; // Replace with the actual file path where you put the StringEncryptor class
import 'package:firebase_login/presentation/home/homeViewModel.dart';

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

  Future<void> saveLoginToken(String token) async {
    _model.loginToken = token;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_model.autoLogin == true) {
      await prefs.setString('token', _model.loginToken);
    } else {
      await prefs.setString('token', "");
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

  Future<void> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("token : $token");  
    _model.loginToken = token;
    _model.autoLogin = prefs.getBool('autoLogin') ?? false;
    if (token.isNotEmpty) {
      _model.autoLogin = false;
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

  
  Future<LoginStatus> AutoPhonelogin(BuildContext context) async {
    final api = FirebaseAPI();
    final alarm = AlarmService.instance;
    await api.logout();

    String token = _model.loginToken;
    final userinfo = await api.loginWithToken(token);
    if (userinfo!.user!.uid.isEmpty) {
      return LoginStatus.logined;
    }
    final uid = userinfo!.user!.uid.toString();
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sellViewModel = Provider.of<SellViewModel>(context, listen: false);
    final myPageViewModel =
        Provider.of<MypageViewModel>(context, listen: false);

    homeViewModel.categorymodel.clearcategories();
    sellViewModel.categorymodel.clearcategories();
    myPageViewModel.categorymodel.clearcategories();

    final category = await api.getAllCategoriesOnCallFunction();
    if (category.isNotEmpty) {
      for (final item in category) {
        homeViewModel.categorymodel.addcategory(item['id'].toString());
        sellViewModel.categorymodel.addcategory(item['id'].toString());
        myPageViewModel.categorymodel.addcategory(item['id'].toString());
      }
    } else {
      print("error getAllCategoriesOnCallFunction function");
    }

    final devicetoken =
        await api.addDeviceTokenOnCallFunction(uid, alarm.fcmToken.toString());
    if (devicetoken) {
      _userService.startListeningToUserDataChanges(uid);
      alarm.startListeningToNotifications(uid);
      myPageViewModel.startListeningToFollowers(uid);
      myPageViewModel.startListeningToFollowing(uid);
    } else {
      print("error addDeviceTokenOnCallFunction function");
    }

    return LoginStatus.success;
  }

  Future<LoginStatus> Phonelogin(BuildContext context) async {
    final api = FirebaseAPI();
    final alarm = AlarmService.instance;

    // Phone Auth Logout
    await api.logout();

    final token = await api.loginwithPhone(_model.uid, _model.phone);
    if (token.isNotEmpty) {
      final delete =
          await api.deleteUserFromPhnoeAuth(_model.uid, _model.phone);
      if (!delete) {
        return LoginStatus.deleted;
      }
    } else {
      return LoginStatus.cretedtoken;
    }

    saveLoginToken(token);
    
    final userinfo = await api.loginWithToken(token);
    if (userinfo!.user!.uid.isEmpty) {
      return LoginStatus.logined;
    }
    final uid = userinfo!.user!.uid.toString();
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sellViewModel = Provider.of<SellViewModel>(context, listen: false);
    final myPageViewModel =
        Provider.of<MypageViewModel>(context, listen: false);

    homeViewModel.categorymodel.clearcategories();
    sellViewModel.categorymodel.clearcategories();
    myPageViewModel.categorymodel.clearcategories();

    final category = await api.getAllCategoriesOnCallFunction();
    if (category.isNotEmpty) {
      for (final item in category) {
        homeViewModel.categorymodel.addcategory(item['id'].toString());
        sellViewModel.categorymodel.addcategory(item['id'].toString());
        myPageViewModel.categorymodel.addcategory(item['id'].toString());
      }
    }else{
      print("error getAllCategoriesOnCallFunction function");
    }

    final devicetoken =
        await api.addDeviceTokenOnCallFunction(uid, alarm.fcmToken.toString());
    if (devicetoken) {
      _userService.startListeningToUserDataChanges(uid);
      alarm.startListeningToNotifications(uid);
      myPageViewModel.startListeningToFollowers(uid);
      myPageViewModel.startListeningToFollowing(uid);
    }
    else{
      print("error addDeviceTokenOnCallFunction function");
    }

    return LoginStatus.success;
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
