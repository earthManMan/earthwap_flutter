import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/presentation/login/login_viewmodel.dart';
import 'package:firebase_login/presentation/common/widgets/custom_popup_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
/*
class EmailInput extends StatelessWidget {
  final LoginViewModel _viewmodel;
  final TextEditingController _emailController;

  EmailInput({required LoginViewModel viewmodel, super.key})
      : _viewmodel = viewmodel,
        _emailController = TextEditingController(text: viewmodel.model.email);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        controller: _emailController, // Controller를 연결
        onChanged: (email) {
          _viewmodel.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,

        decoration: const InputDecoration(
          labelStyle:
              TextStyle(fontFamily: "SUIT", fontSize: 14, color: Colors.white),
          labelText: '이메일',
          helperText: '',
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  final LoginViewModel _viewmodel;
  final TextEditingController _passwordController;

  PasswordInput({required LoginViewModel viewmodel, super.key})
      : _viewmodel = viewmodel,
        _passwordController =
            TextEditingController(text: viewmodel.model.password);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        enableInteractiveSelection: true,
        controller: _passwordController, // Controller를 연결
        onChanged: (password) {
          _viewmodel.setPassword(password);
        },
        obscureText: true,
        decoration: const InputDecoration(
          labelText: '비밀번호',
          labelStyle:
              TextStyle(fontFamily: "SUIT", fontSize: 14, color: Colors.white),
          helperText: '',
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  final LoginViewModel _viewmodel;

  const LoginButton({required LoginViewModel viewmodel, super.key})
      : _viewmodel = viewmodel;

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                if (widget._viewmodel.model.email.isEmpty ||
                    widget._viewmodel.model.password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog(
                        message: "Email 또는 Password를 입력 해 주세요.",
                        visibleCancel: false,
                        visibleConfirm: true,
                      );
                    },
                  );
                } else {
                  setState(() {
                    _isLoading = true;
                  });

                  bool loginSuccess = await widget._viewmodel.login(context);

                  if (loginSuccess) {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    showtoastMessage(
                        '로그인에 실패했습니다. 다시 시도해주세요.', toastStatus.error);
                  }
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
        child: _isLoading
            ? PlatformCircularProgressIndicator(
                material: (context, platform) {
                  return MaterialProgressIndicatorData(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
                cupertino: (context, platform) {
                  return CupertinoProgressIndicatorData(
                    color: AppColor.primary,
                  );
                },
              )
            : const Text(
                '로그인',
                style: TextStyle(
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
      ),
    );
  }
}

class PasswordFind extends StatelessWidget {
  const PasswordFind({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      const Text('비밀번호를 잊으셨나요?', style: TextStyle(color: ColorStyles.text)),
      Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextButton(
            onPressed: () {
              // RegisterAuth Page로 이동
              Navigator.of(context).pushNamed('/password');
            },
            child: const Text('비밀번호 찾기',
                style: TextStyle(
                    color: ColorStyles.primary,
                    fontFamily: "SUIT",
                    fontWeight: FontWeight.bold))),
      )
    ]));
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/register');
      },
      child: Text(
        '이메일로 간단하게 회원가입 하기',
        style: TextStyle(color: theme.primaryColorLight),
      ),
    );
  }
}
*/