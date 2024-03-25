import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const COLLECTION_USERS = 'Users';
const COLLECTION_POSTS = 'Posts';
const COLLECTION_COMMENTS = 'Comments';

const KEY_EMAIL = 'email';
const KEY_LIKEDPOSTS = 'liked_posts';
const KEY_FOLLOWERS = 'followers';
const KEY_FOLLOWINGS = 'followings';
const KEY_MYPOSTS = 'my_posts';
const KEY_USERNAME = 'username';

const KEY_COMMENT = 'comment';
const KEY_COMMENTTIME = 'commenttime';

const KEY_POSTKEY = 'post_key';
const KEY_POSTIMG = 'post_img';
const KEY_CAPTION = 'caption';
const KEY_LASTCOMMENT = 'last_comment';
const KEY_LASTCOMMENTOR = 'last_commentor';
const KEY_LASTCOMMENTTIME = 'last_comment_time';
const KEY_NUMOFLIKES = 'num_of_likes';
const KEY_NUMOFCOMMENTS = 'num_of_comments';
const KEY_POSTTIME = 'post_time';

class LocalStorage {
  final storage = const FlutterSecureStorage();

  Future<void> deleteitem(String key) async {
    await storage.delete(
        key: key, aOptions: AndroidOptions(encryptedSharedPreferences: true));
  }

  Future<String?> getitem(String key) async {
    final item = await storage.read(
        key: key, aOptions: AndroidOptions(encryptedSharedPreferences: true));

    if (item != null) {
      return item;
    } else {
      return "";
    }
  }

  Future<void> saveitem(String key, String value) async {
    await storage.write(
        key: key,
        value: value,
        aOptions: AndroidOptions(encryptedSharedPreferences: true));
  }
}
