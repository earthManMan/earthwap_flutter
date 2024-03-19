import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_login/domain/alarm/alarm_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmService with ChangeNotifier {
  final List<alarmModel> _alarms = [];
  String fcmToken = "";
  NotificationSettings? _settings;
  bool _alaramStatus = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationListener;

  bool get isNotificationEnabled =>
      _settings?.authorizationStatus == AuthorizationStatus.authorized;
  static const String _notificationSettingsKey = 'notificationSettings';

  AlarmService._privateConstructor();

  static final AlarmService _instance = AlarmService._privateConstructor();

  static AlarmService get instance => _instance;

  List<alarmModel>? get alarms => _alarms;

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    final item = alarmModel(
        id: "",
        title: message.notification!.title,
        body: message.notification!.body,
        read: false);
    AlarmService.instance._alarms.add(item);
  }

  void setReadMessage() {
    for (final message in _alarms) {
      readUpdateField(message);
      message.read = true;
    }
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    // Load saved notification settings from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getString(_notificationSettingsKey);
    await prefs.setString(_notificationSettingsKey, enabled.toString());

    final value = await FirebaseMessaging.instance.requestPermission(
      alert: enabled,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: enabled,
    );
    _settings = value;
    _alaramStatus = enabled;
    notifyListeners();

    if (!enabled) {
      FirebaseMessaging.onBackgroundMessage((message) async {});
      stopListeningToNotifications();
      //stopListeningToMessages();
    } else {
      //startListeningToMessages();
      startListeningToNotifications(UserService.instance.uid!);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }

  void readUpdateField(alarmModel message) async {
    if (message.id!.isEmpty || message.read == true) return;

    final user = UserService.instance;
    final userDocRef = FirebaseFirestore.instance
        .collection('/notifications/')
        .doc(user.uid)
        .collection('/notifications/')
        .doc(message.id!);

    final data = {'read_at': DateTime.now().toString()};

    try {
      await userDocRef.update(data);
    } catch (error) {
      print("문서 업데이트 실패: $error");
    }
  }

  bool isNotReadMessage() {
    bool state = false;
    for (var element in _alarms) {
      if (element.read == false) state = true;
    }
    return state;
  }

  void startListeningToNotifications(String uid) {
    _notificationListener?.cancel();

    final userDocRef = FirebaseFirestore.instance
        .collection('/notifications/')
        .doc(uid)
        .collection('/notifications/');

    _notificationListener = userDocRef.snapshots().listen((event) {
      if (_alaramStatus) {
        _alarms.clear();
        for (final doc in event.docs) {
          final msg = doc.data();
          if (msg['read_at'] == null) {
            final item = alarmModel(
              id: doc.id.toString(),
              title: msg['title'].toString(),
              body: msg['body'].toString(),
              read: false,
            );
            _alarms.add(item);
          }
        }
        notifyListeners();
      }
    });
  }

  void stopListeningToNotifications() {
    _notificationListener?.cancel();
  }

  Future<bool> settingAlarm() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    // Load saved notification settings from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getString(_notificationSettingsKey);

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) fcmToken = token;

    if (savedSettings == null) {
      bool enable = true;
      prefs.setString(_notificationSettingsKey, enable.toString());
      _alaramStatus = true;
    }

    // If the notification settings are not authorized, request permission
    if (prefs.getString(_notificationSettingsKey).toString() == "true") {
      _alaramStatus = true;
      final value = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _settings = value;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      //startListeningToMessages();
      return true;
    }
    return true;
  }

  void _onMessageReceived(RemoteMessage? message) {
    if (message != null && message.notification != null) {
      if (_alaramStatus) {
        final item = alarmModel(
          id: "",
          title: message.notification!.title,
          body: message.notification!.body,
          read: false,
        );
        _alarms.add(item);
        notifyListeners();
      }
    }
  }

  void startListeningToMessages() {
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
  }

  void stopListeningToMessages() {
    FirebaseMessaging.onMessage.drain();
  }

  bool getAlaramStatus() {
    return _alaramStatus;
  }

  void clearAlaram() {
    _alarms.clear();
  }
}
