import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/domain/login/login_model.dart';
import 'package:firebase_login/presentation/login/loginViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/login/components/loginComp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_login/presentation/register/registerViewModel.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _authController = TextEditingController();

  bool _isphoneInput = true;
  bool _isAuthCodeInput = false;
  bool _isvalid = false;
  bool _isLoading = false;
  bool _isAutoLogin = false;
  // SharedPreferences 인스턴스를 저장하기 위한 변수
  late SharedPreferences _prefs;

  @override
  void initState() {
    // 여기에서 저장된 설정을 읽고 초기 상태를 설정합니다.
    // 예: SharedPreferences를 사용하여 설정을 읽을 수 있습니다.
    super.initState();
    _initializeSharedPreferences();
  }

  void _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('autoLogin') ?? false) {
      setState(() {
        _isAutoLogin = true;
      });
      // 자동 로그인 설정이 활성화되어 있다면 자동으로 로그인 시도
      final loggedIn =
          await context.read<LoginViewModel>().AutoPhonelogin(context);
      if (loggedIn == LoginStatus.success) {
        // 자동 로그인 성공 시 메인 페이지로 이동
        Navigator.pushReplacementNamed(context, '/main');
      }else{
        showSnackbar(context,"로그인에 실패 했습니다. 다시 로그인 해주세요.");
        setState(() {
          _isAutoLogin = false;  
        });
        
      }
    }
  }

  bool isPhoneValid(String phone) {
    // 핸드폰 번호 형식을 검증하는 정규 표현식
    final RegExp phoneRegex = RegExp(
      r'^01(?:0|1|[6-9])(\d{3}|\d{4})\d{4}$',
    );

    // Remove hyphens from the phone number
    String phoneNumberWithoutHyphen = phone.replaceAll('-', '');

    return phoneRegex.hasMatch(phoneNumberWithoutHyphen);
  }

  void _checkPhoneValidity(String value, LoginViewModel ViewModel) {
    setState(() {
      _isvalid = isPhoneValid(value);
      ViewModel.model.phone = '+82' + value.substring(1);
      print(ViewModel.model.phone.toString());
    });
  }

  // SharedPreferences 초기화 메서드
  void _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // LoginViewModel을 업데이트하여 설정 값을 반영합니다.
    await context.read<LoginViewModel>().getLoginToken();
   // _checkAutoLogin(); // 자동 로그인 설정 확인
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
            body: _isAutoLogin
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "로그인 중입니다...",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: 50, // 원하는 너비로 설정
                          height: 50, // 원하는 높이로 설정
                          child: PlatformCircularProgressIndicator(),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              _isphoneInput
                                  ? "휴대폰 번호로 로그인해주세요."
                                  : "인증코드를 입력 해주세요.",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                        if (_isphoneInput)
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              keyboardAppearance:
                                  Brightness.dark, // Add this line
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                // You can add more formatters if needed
                              ],
                              onChanged: _isphoneInput
                                  ? (value) =>
                                      _checkPhoneValidity(value, loginViewModel)
                                  : null,
                              enableInteractiveSelection: _isphoneInput,
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: "휴대폰 번호(- 없이 숫자만 입력)",
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7.0)),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (_isAuthCodeInput)
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              keyboardAppearance:
                                  Brightness.dark, // Add this line
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                // You can add more formatters if needed
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (_authController.text.isNotEmpty)
                                    _isvalid = true;
                                  else {
                                    _isvalid = false;
                                  }
                                });
                              },
                              enableInteractiveSelection: _isAuthCodeInput,
                              controller: _authController,
                              decoration: InputDecoration(
                                hintText: "인증코드",
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7.0)),
                                ),
                                errorText: _isvalid ? null : '인증번호가 일치하지 않습니다.',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                          color: Color.fromARGB(
                                              255, 216, 208, 208))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.2,
                          alignment: Alignment.bottomCenter,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : TextRoundButton(
                                  text: _isAuthCodeInput
                                      ? "인증 코드 확인"
                                      : "인증 문자 받기",
                                  enable: _isvalid,
                                  call: () async {
                                    if (_isphoneInput) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await loginViewModel
                                          .PhoneCodeSendButtonPressed();
                                      setState(() {
                                        _isLoading = false;
                                        _isphoneInput = false;
                                        _isAuthCodeInput = true;
                                        _isvalid = false;
                                      });
                                    } else if (_isAuthCodeInput) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      final smscode = await loginViewModel
                                          .signInWithSMSCode(
                                              _authController.text.toString());

                                      if (smscode) {
                                        final login =
                                            await loginViewModel.Phonelogin(
                                                context);
                                        if (login == LoginStatus.cretedtoken) {
                                          //TODO : 해당 계정의 토큰이 이미 있는경우 ?
                                          print("토큰 발행 실패");
                                        } else if (login ==
                                            LoginStatus.deleted) {
                                          print("폰 계정 삭제 실패");
                                        } else if (login ==
                                            LoginStatus.logined) {
                                          print("토큰으로 계정 로그인 실패");
                                        } else if (login ==
                                            LoginStatus.success) {
                                          Navigator.pushReplacementNamed(
                                              context, '/main');
                                        }
                                      } else {
                                        showSnackbar(
                                            context, "인증 코드를 다시 확인해주세요.");
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
