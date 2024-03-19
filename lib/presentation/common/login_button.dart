import 'package:flutter/material.dart';
import 'package:firebase_login/app/style/app_color.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Text('이미 계정이 있으신가요? 바로',
              style: TextStyle(color: AppColor.text)),
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
                        color: AppColor.primary))),
          )
        ]));
  }
}
