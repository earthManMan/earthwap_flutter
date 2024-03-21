import 'package:firebase_login/presentation/login/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/login/old/loginComp.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // SharedPreferences 인스턴스를 저장하기 위한 변수
  late SharedPreferences _prefs;

  @override
  void initState() {
    // 여기에서 저장된 설정을 읽고 초기 상태를 설정합니다.
    // 예: SharedPreferences를 사용하여 설정을 읽을 수 있습니다.
    super.initState();
    _initializeSharedPreferences();
  }

  // SharedPreferences 초기화 메서드
  void _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // LoginViewModel을 업데이트하여 설정 값을 반영합니다.
    await context.read<LoginViewModel>().getLoginInfo();
  }

  // 사용자 설정을 저장하는 메서드
  void saveSettings() {
    // 사용자 설정을 SharedPreferences에 저장합니다.
    _prefs.setBool(
        'rememberEmail', context.read<LoginViewModel>().model.rememberEmail);
    _prefs.setBool('autoLogin', context.read<LoginViewModel>().model.autoLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, loginViewModel, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/components/background.png'), // 배경 이미지
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 240, 244, 248), //색변경
              ),
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  /*   Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 0),
                    child: Center(
                      child: Text(
                        "HELLO,\nEARTH!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: ColorStyles.primary,
                            fontFamily: "Syncopate"),
                      ),
                    ),
                  ),*/
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 0),
                  ),
                  EmailInput(viewmodel: loginViewModel),
                  PasswordInput(viewmodel: loginViewModel),
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: loginViewModel.model.rememberEmail,
                              onChanged: (value) {
                                setState(() {
                                  loginViewModel.updateRememberEmail(value!);
                                  saveSettings(); // 변경된 설정을 저장
                                });
                              },
                            ),
                            const Text('이메일 저장',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 216, 208, 208))),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: loginViewModel.model.autoLogin,
                              onChanged: (value) {
                                setState(() {
                                  loginViewModel.updateAutoLogin(value!);
                                  saveSettings(); // 변경된 설정을 저장
                                });
                              },
                            ),
                            const Text('자동 로그인',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 216, 208, 208))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PasswordFind(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.2,
                    alignment: Alignment.bottomCenter,
                    child: LoginButton(viewmodel: loginViewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
*/