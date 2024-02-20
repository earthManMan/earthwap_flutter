import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'dart:async';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Private constructor to prevent external instantiation
  RemoteConfigService._privateConstructor();

  // Singleton instance
  static final RemoteConfigService _instance =
      RemoteConfigService._privateConstructor();

  // Getter for the singleton instance
  static RemoteConfigService get instance => _instance;
  Future<bool> initialize() async {
    final Completer<bool> completer = Completer<bool>();

    try {
      _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration.zero,
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.fetchAndActivate().then((_) {
        print(_remoteConfig.getValue("resources").asString());
        completer.complete(true);
      });

      return completer.future;
    } on Exception catch (e) {
      print("Error fetching or activating remote config: $e");
      completer.complete(false);
      return completer.future;
    }
  }

  Map<String, dynamic> getbootPay() {
    String jsonString = _remoteConfig.getValue("bootpay_keys").asString();
    Map<String, dynamic> valueList =
        Map<String, dynamic>.from(json.decode(jsonString));
    return valueList;
  }

  String getPrivacyPolicy() {
    String value = _remoteConfig.getValue("privacy_policy").asString();
    return value;
  }

  String getAppVersion() {
    String value = _remoteConfig.getValue("version").asString();
    return value;
  }

  List<Map<String, dynamic>> getStartModelJsonMap() {
    String jsonString = _remoteConfig.getValue("start_model").asString();
    List<Map<String, dynamic>> valueList =
        List<Map<String, dynamic>>.from(json.decode(jsonString));
    return valueList;
  }

  Map<String, dynamic> getSellModelJsonMap() {
    String jsonString = _remoteConfig.getValue("sell_model").asString();
    Map<String, dynamic> valueList =
        Map<String, dynamic>.from(json.decode(jsonString));
    return valueList;
  }

  Map<String, dynamic> getCustomerServiceJsonMap() {
    String jsonString = _remoteConfig.getValue("customerservice").asString();
    Map<String, dynamic> valueList =
        Map<String, dynamic>.from(json.decode(jsonString));
    return valueList;
  }

  List<Map<String, dynamic>> getPaymentInfoJsonMap() {
    String jsonString = _remoteConfig.getValue("paymentinfo").asString();
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Access the "instructions" key which contains the list
    List<Map<String, dynamic>> valueList =
        List<Map<String, dynamic>>.from(jsonData["instructions"]);

    return valueList;
  }

  Map<String, dynamic> getimages() {
    String jsonString = _remoteConfig.getValue("resources").asString();
    if (jsonString.isNotEmpty) {
      Map<String, dynamic> valueList =
          Map<String, dynamic>.from(json.decode(jsonString));

      return valueList;
    } else {
      Map<String, dynamic> valueList = {};
      return valueList;
    }
  }
}
