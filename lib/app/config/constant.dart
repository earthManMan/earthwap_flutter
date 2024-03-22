enum RegistrationStatus {
  registered, // user 생성 실패
  deleted, // Phone User 삭제 실패
  success,
  error,
}
enum LoginStatus {
  cretedtoken, // loginwithPhone 실패 (Token 발생 x)
  deleted, // Phone User 삭제 실패
  logined, // loginWithToken 실패
  success,
}
enum UploadType {
  cover,
  other,
  community,
  profile,
}
enum EmailType {
  Verification,
  ChangePassword,
}
enum toastStatus {
  info,
  error,
  success,
}
enum ChatMessageType {
  sent,
  received,
}


const KEY_TOKEN = 'token';
const KEY_AUTOLOGIN = 'autologin';