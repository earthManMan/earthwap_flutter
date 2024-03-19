import 'package:flutter/material.dart';
import 'package:firebase_login/domain/register/register_model.dart';

import 'package:firebase_login/presentation/register/registerViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/util/validateText_util.dart';
import 'package:firebase_login/presentation/common/login_button.dart';
import 'package:firebase_login/app/style/app_color.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _authController = TextEditingController();

  bool _isphoneInput = true;
  bool _isAuthCodeInput = false;
  bool _isLoading = false;
  bool _isvalid = false;

  void _checkPhoneValidity(String value, RegisterViewModel registerViewModel) {
    setState(() {
      _isvalid = isPhoneValid(value);
      registerViewModel.model.phone = '+82' + value.substring(1);
    });
  }

  void _checkPasswordValidity(
      String value, RegisterViewModel registerViewModel) {
    setState(() {
      _isvalid = value.length >= 6;
      registerViewModel.model.password = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<RegisterViewModel>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/components/background.png'),
        ),
      ),
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          material: (context, platform) {
            return MaterialAppBarData(
                iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 240, 244, 248),
            ));
          },
        ),
        backgroundColor: Colors.transparent,
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
                      color: AppColor.grayF9,
                    ),
                  ),
                ),
              ),
              if (_isphoneInput)
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: PlatformTextField(
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.dark, // Add this line
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      // You can add more formatters if needed
                    ],
                    onChanged: _isphoneInput
                        ? (value) => _checkPhoneValidity(value, viewmodel)
                        : null,
                    enableInteractiveSelection: _isphoneInput,
                    controller: _phoneController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColor.grayF9,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "휴대폰 번호(- 없이 숫자만 입력)",
                    material: (context, platform) {
                      return MaterialTextFieldData(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(7.0)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_isAuthCodeInput)
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: PlatformTextField(
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColor.grayF9,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "인증코드",
                    material: (context, platform) {
                      return MaterialTextFieldData(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(7.0)),
                          ),
                          errorText: _isvalid ? null : '인증번호가 일치하지 않습니다.',
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 10),
                child: _isLoading
                    ? PlatformCircularProgressIndicator()
                    : TextRoundButton(
                        text: _isAuthCodeInput ? "인증 코드 확인" : "인증 문자 받기",
                        enable: _isvalid,
                        call: () async {
                          if (_isphoneInput) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              await viewmodel.PhoneCodeSendButtonPressed();

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
                            final check = await viewmodel.signInWithSMSCode(
                                _authController.text.toString());
                            if (check) {
                              final register = await viewmodel.registerUser();
                              if (register == RegistrationStatus.success) {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else if (register ==
                                  RegistrationStatus.deleted) {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else if (register ==
                                  RegistrationStatus.registered) {
                                setState(() {
                                  _isLoading = false;
                                });
                                showSnackbar(context, "계정 생성 실패 했습니다.");
                              }
                            } else {
                              setState(() {
                                _isLoading = false;
                              });
                              showSnackbar(context, "인증 코드를 다시 확인해주세요.");
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
  }
}
