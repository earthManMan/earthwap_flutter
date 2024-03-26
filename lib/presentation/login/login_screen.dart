import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/presentation/login/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/util/validateText_util.dart';

import 'package:flutter/cupertino.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/app/style/app_color.dart';

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
  bool _isAutoLogin = false; // 자동 로그인 체크박스 활성화 및 자동로그인 함수 호출
  bool _checkbox = false;

  String _phonenumber = "";
  String _authcode = "";

  @override
  void initState() {
    super.initState();
    // 자동 로그인 체크
   // _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    // viewmodel로 부터 LocalStorage에 저장되어 있는 자동로그인 변수 체크
    final viewmodel = context.read<LoginViewModel>();
    final result = await viewmodel.checkAutoLogin();

    if (result) {
      setState(() {
        _isAutoLogin = result;
      });

      // 자동 로그인 진행
      final loginstatus = await viewmodel.AutoPhonelogin(context);
      if (loginstatus == LoginStatus.success) {
        // 자동 로그인 성공 시 메인 페이지로 이동
        Navigator.pushReplacementNamed(context, '/main');
        showtoastMessage("안녕하세요. 어스왑입니다~", toastStatus.success);
      } else {
        showtoastMessage("로그인에 실패 했습니다. 다시 로그인 해주세요.", toastStatus.error);
        setState(() {
          _isAutoLogin = false;
        });
      }
    }
  }

  void _checkPhoneValidity(String value, LoginViewModel ViewModel) {
    if (value.isNotEmpty)
      setState(() {
        _isvalid = isPhoneValid(value);
        _phonenumber = '+82' + value.substring(1);
      });
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<LoginViewModel>(context, listen: false);

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
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.grayF9,
            ),
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
              backgroundColor: Colors.transparent,
            );
          },
        ),
        backgroundColor: Colors.transparent,
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
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        )),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight),
                child: Column(
                  children: [
                    _buildTitle(),
                    _buildInputWidget(_isphoneInput, viewmodel),
                    _buildAutoLogin(viewmodel),
                    _buildLogin(viewmodel)
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          _isphoneInput ? "휴대폰 번호로 로그인해주세요." : "인증코드를 입력 해주세요.",
          style: TextStyle(
            fontSize: 20,
            color: AppColor.grayF9,
          ),
        ),
      ),
    );
  }

  Widget _buildInputWidget(bool isPhoneInput, LoginViewModel viewmodel) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: PlatformTextField(
        keyboardType: TextInputType.number,
        keyboardAppearance: Brightness.dark,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: isPhoneInput
            ? (value) => _checkPhoneValidity(value, viewmodel)
            : (value) {
                _authcode = _authController.text;
                setState(() {
                  if (_authController.text.isNotEmpty) {
                    _isvalid = true;
                  } else {
                    _isvalid = false;
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
              suffixIcon: _buildClearButton(isPhoneInput, viewmodel),
              errorText:
                  isPhoneInput ? null : (_isvalid ? null : '인증번호가 일치하지 않습니다.'),
            ),
          );
        },
        cupertino: (context, platform) {
          return CupertinoTextFieldData(
            suffix: _buildClearButton(isPhoneInput, viewmodel),
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

  Widget _buildClearButton(bool isPhoneInput, LoginViewModel viewmodel) {
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

  Widget _buildAutoLogin(LoginViewModel viewmodel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('자동 로그인', style: TextStyle(color: AppColor.grayF9)),
          Padding(padding: EdgeInsets.all(5)),
          PlatformSwitch(
            activeColor: AppColor.primary,
            value: _checkbox,
            onChanged: (value) {
              setState(() {
                viewmodel.saveAutoLogin(value!);
                _checkbox = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogin(LoginViewModel viewmodel) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      alignment: Alignment.bottomCenter,
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
                  await viewmodel.sendPhoneCode(_phonenumber);

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

                  final smscode = await viewmodel.verifySMSCode(_authcode);

                  if (smscode) {
                    final login = await viewmodel.Phonelogin(context);
                    if (login == LoginStatus.cretedtoken) {
                      showtoastMessage("회원가입을 먼저 진행 해주세요.", toastStatus.error);
                      setState(() {
                        _isLoading = false;
                      });
                    } else if (login == LoginStatus.deleted) {
                      print("폰 계정 삭제 실패");
                    } else if (login == LoginStatus.logined) {
                      print("토큰으로 계정 로그인 실패");
                    } else if (login == LoginStatus.success) {
                      Navigator.pushReplacementNamed(context, '/main');
                      showtoastMessage("안녕하세요. 어스왑입니다~", toastStatus.success);
                    }
                  } else {
                    showtoastMessage("인증 코드를 다시 확인해주세요.", toastStatus.error);
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
    );
  }
}
