import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_login/app/config/app_const.dart';

class EmailUtil {
  final List<String> _recipients = [AppConst.ticatsEmail];

  Future<void> sendInqueryEmail() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String deviceName = '';
    String deviceVersion = '';
    String packageVersion = packageInfo.version;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

      deviceName = androidDeviceInfo.model;
      deviceVersion = androidDeviceInfo.version.toString();
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;

      deviceName = iosDeviceInfo.name;
      deviceVersion = iosDeviceInfo.systemVersion;
    }

    await _sendEmail(
      '[티캣츠 운영 문의]',
      '''안녕하세요 :) 티캣츠에 문의 주셔서 감사합니다.
아래 내용을 보내주시면 문의사항을 처리하는 데 도움이 됩니다.

문의사항 :

핸드폰 기종 : $deviceName
핸드폰 버전 : $deviceVersion
티캣츠 버전 : $packageVersion

감사합니다. 항상 노력하는 티캣츠가 되겠습니다.
''',
    );
  }

  Future<void> sendReportEmail(int ticketId) async {
    await _sendEmail(
      '[티캣츠 티켓 신고]',
      '''안녕하세요 :) 티캣츠입니다.
티켓이 많이 불편하셨나요?
아래 내용을 보내주시면 해결하는 데 도움이 됩니다.

티켓 신고 사유 :

티켓 ID : $ticketId

감사합니다. 항상 노력하는 티캣츠가 되겠습니다.
''',
    );
  }

  Future<void> _sendEmail(String subject, String body) async {
    final Email email = Email(
      recipients: _recipients,
      subject: subject,
      body: body,
      cc: [],
      bcc: [],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
