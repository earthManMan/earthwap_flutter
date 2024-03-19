bool isPhoneValid(String phone) {
  // 핸드폰 번호 형식을 검증하는 정규 표현식
  final RegExp phoneRegex = RegExp(
    r'^01(?:0|1|[6-9])(\d{3}|\d{4})\d{4}$',
  );

  // Remove hyphens from the phone number
  String phoneNumberWithoutHyphen = phone.replaceAll('-', '');

  return phoneRegex.hasMatch(phoneNumberWithoutHyphen);
}
