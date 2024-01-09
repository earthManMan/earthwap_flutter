import 'package:firebase_login/model/sellModel.dart';
import 'package:firebase_login/viewModel/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_login/model/sellModel.dart';
import 'package:provider/provider.dart';

class KeyWordPopup extends Dialog {
  const KeyWordPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<SellViewModel>(context, listen: false);

    // TODO: implement build
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.1),
      insetPadding: EdgeInsets.zero,
      child: AlertDialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.1),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100.0),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  animationDuration: Duration.zero,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('TIP', style: TextStyle(color: Colors.white)),
                onPressed: () {},
              ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text(
                    ViewModel.model.getKeywordDescription().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: ColorStyles.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Color.fromARGB(255, 240, 244, 248),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      child: const Text('오늘 그만 보기',
                          style: TextStyle(
                            color: Color.fromARGB(255, 240, 244, 248),
                          )),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isKeywordPopup', true);

                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  bool? visibleConfirm = true;
  bool? visibleCancel = true;

  CustomAlertDialog({
    super.key,
    required this.message,
    this.onConfirm,
    this.onCancel,
    required this.visibleConfirm,
    required this.visibleCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: ColorStyles.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "SUIT",
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (visibleConfirm!)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onConfirm != null) {
                          onConfirm!();
                        }
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(
                            fontSize: 18,
                            color: ColorStyles.text,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  SizedBox(width: 10),
                  if (visibleCancel!)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        if (onCancel != null) {
                          onCancel!();
                        }
                      },
                      child: Text(
                        '취소',
                        style: TextStyle(
                            fontSize: 18,
                            color: ColorStyles.text,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
