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

import 'package:flutter/cupertino.dart';

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

  String _phonenumber = "";
  String _authcode = "";

  void _checkPhoneValidity(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _isvalid = isPhoneValid(value);
        _phonenumber = '+82' + value.substring(1);
      });
    }
  }

  Widget _buildTitle() {
    return Padding(
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
    );
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
          leading: PlatformIconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          material: (context, platform) {
            return MaterialAppBarData(
                iconTheme: const IconThemeData(
              color: AppColor.grayF9,
            ));
          },
          cupertino: (context, platform) {
            return CupertinoNavigationBarData(
              backgroundColor: AppColor.grayF9,
            );
          },
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildTitle(),
              _buildInputWidget(_isphoneInput),
              _buildRegisterButton(viewmodel),
              const LoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputWidget(bool isPhoneInput) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: PlatformTextField(
        keyboardType: TextInputType.number,
        keyboardAppearance: Brightness.dark,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: isPhoneInput
            ? (value) => _checkPhoneValidity(value)
            : (value) {
                setState(() {
                  if (_authController.text.isNotEmpty) {
                    _isvalid = true;
                    _authcode = _authController.text.toString();
                  } else {
                    _isvalid = false;
                    _authcode = "";
                  }
                });
              },
        enabled: isPhoneInput ? _isphoneInput : _isAuthCodeInput,
        controller: isPhoneInput ? _phoneController : _authController,
        style: const TextStyle(
          fontSize: 16,
          color: AppColor.grayF9,
          fontWeight: FontWeight.bold,
        ),
        hintText: isPhoneInput ? "휴대폰 번호(- 없이 숫자만 입력)" : "인증코드",
        material: (context, platform) {
          return MaterialTextFieldData(
            decoration: InputDecoration(
              suffixIcon: _buildClearButton(isPhoneInput),
              errorText:
                  isPhoneInput ? null : (_isvalid ? null : '인증번호가 일치하지 않습니다.'),
            ),
          );
        },
        cupertino: (context, platform) {
          return CupertinoTextFieldData(
            suffix: _buildClearButton(isPhoneInput),
            placeholder:
                isPhoneInput ? null : (_isvalid ? null : '인증번호가 일치하지 않습니다.'),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColor.grayF9,
                  width: 0.5, // Adjust the width as needed
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClearButton(bool isPhoneInput) {
    return GestureDetector(
      onTap: () {
        if (isPhoneInput) {
          setState(() {
            _isvalid = false;
            _phonenumber = "";
            _phoneController.clear();
          });
        } else {
          setState(() {
            _isvalid = false;
            _authcode = "";
            _authController.clear();
          });
        }
      },
      child: Icon(
        CupertinoIcons.clear_thick_circled,
        color: CupertinoColors.systemGrey,
      ),
    );
  }

  Widget _buildRegisterButton(RegisterViewModel viewmodel) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 10),
      child: _isLoading
          ? PlatformCircularProgressIndicator(
              cupertino: (context, platform) {
                return CupertinoProgressIndicatorData(
                  color: AppColor.primary,
                );
              },
            )
          : TextRoundButton(
              text: _isAuthCodeInput ? "인증 코드 확인" : "인증 문자 받기",
              enable: _isvalid,
              call: () async {
                if (_isphoneInput) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await viewmodel.PhoneCodeSendButtonPressed(_phonenumber);

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
                      print("sendEmailVerification failed with error: $error");
                    });
                  }
                } else if (_isAuthCodeInput) {
                  setState(() {
                    _isLoading = true;
                  });
                  final check = await viewmodel.signInWithSMSCode(_authcode);
                  if (check) {
                    final register = await viewmodel.registerUser(_phonenumber);
                    if (register == RegistrationStatus.success) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else if (register == RegistrationStatus.deleted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else if (register == RegistrationStatus.registered) {
                      setState(() {
                        _isLoading = false;
                      });
                      showtoastMessage("계정 생성 실패 했습니다.", toastStatus.error);
                    }
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    showtoastMessage("인증 코드를 다시 확인해주세요.", toastStatus.error);
                  }
                }
              },
            ),
    );
  }
}
