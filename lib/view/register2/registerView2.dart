import 'package:firebase_login/model/registerModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/viewModel/registerViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/components/common_components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RegisterView2 extends StatefulWidget {
  const RegisterView2({Key? key}) : super(key: key);

  @override
  _RegisterView2State createState() => _RegisterView2State();
}

class _RegisterView2State extends State<RegisterView2> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _authController = TextEditingController();

  bool _isphoneInput = true;
  bool _isAuthCodeInput = false;
  bool _isLoading = false;
  bool _isvalid = false;
  bool _obscureText = true;

  bool isPhoneValid(String phone) {
    // 핸드폰 번호 형식을 검증하는 정규 표현식
    final RegExp phoneRegex = RegExp(
      r'^01(?:0|1|[6-9])(\d{3}|\d{4})\d{4}$',
    );

    // Remove hyphens from the phone number
    String phoneNumberWithoutHyphen = phone.replaceAll('-', '');

    return phoneRegex.hasMatch(phoneNumberWithoutHyphen);
  }

  void _checkPhoneValidity(String value, RegisterViewModel registerViewModel) {
    setState(() {
      _isvalid = isPhoneValid(value);
      registerViewModel.model.phone ='+82' + value.substring(1);
      print(registerViewModel.model.phone.toString());
    });
  }

  void _checkPasswordValidity(
      String value, RegisterViewModel registerViewModel) {
    setState(() {
      registerViewModel.model.password = value;
      _isvalid = value.length >= 6;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, registerViewModel, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/components/background.png'),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 240, 244, 248),
              ),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        _isphoneInput
                            ? "휴대폰 번호로 가입해주세요."
                            : _isAuthCodeInput
                                ? "인증코드를 입력 해주세요."
                                : "",
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
                        keyboardAppearance: Brightness.dark, // Add this line
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          // You can add more formatters if needed
                        ],
                        onChanged: _isphoneInput
                            ? (value) =>
                                _checkPhoneValidity(value, registerViewModel)
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
                        keyboardAppearance: Brightness.dark, // Add this line
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
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: _isLoading
                        ?  PlatformCircularProgressIndicator()
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

                                try {                                  
                                   await registerViewModel
                                      .PhoneCodeSendButtonPressed();
                    
                                    setState(() {
                                    _isphoneInput = false;
                                    _isLoading = false;
                                    _isvalid = false;
                                    _isAuthCodeInput = true;
                                  });
                                } catch (error) {
                                  setState(() {
                                    _isLoading = false;
                                    _isAuthCodeInput = false;
                                    _isvalid = false;
                                    print(
                                        "sendEmailVerification failed with error: $error");
                                  });
                                }
                              } else if (_isAuthCodeInput) {
                                setState(() {
                                  _isLoading = true;
                                });   
                                final check = await registerViewModel
                                    .signInWithSMSCode(_authController.text.toString());
                                if(check)
                                {
                                    final register = await registerViewModel
                                    .registerUser();  
                                    if(register == RegistrationStatus.success)
                                    {
                                        Navigator.pushReplacementNamed(
                                        context, '/login');
                                    }else if(register == RegistrationStatus.deleted)
                                    {
                                        Navigator.pushReplacementNamed(
                                        context, '/login');
                                    } else if(register == RegistrationStatus.registered)
                                    {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                      showSnackbar(context,"계정 생성 실패 했습니다.");
                                    }
                                }else{
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  showSnackbar(context,"인증 코드를 다시 확인해주세요.");
                                }
                              } 
                            },
                          ),
                  ),
                  const LoginButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.05,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Text('이미 계정이 있으신가요? 바로',
              style: TextStyle(color: ColorStyles.text)),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextButton(
                onPressed: () {
                  // Login Page로 이동
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('로그인하세요',
                    style: TextStyle(
                        fontFamily: "SUIT",
                        fontWeight: FontWeight.bold,
                        color: ColorStyles.primary))),
          )
        ]));
  }
}
