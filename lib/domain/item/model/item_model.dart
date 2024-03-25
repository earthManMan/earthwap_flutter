import 'package:flutter/material.dart';

class ItemModel {
  String _owned_by = "";

  Color _main_color = Colors.blue;
  Color _sub_color = Colors.amber;

  String _category = "";
  String _main_keyword = "";
  String _sub_keyword = "";

  String _item_description = "";

  String _cover_image_path = "";
  List<String> _other_image_paths = [];

  int _user_price = 0;
  int _price_start = -100;
  int _price_end = 100;

  String _trade_option = "";
  bool _is_premium = false;
  String _location = "";

  ItemModel({
    String ownedBy = "",
    Color mainColor = Colors.blue,
    Color subColor = Colors.amber,
    String category = "",
    String mainKeyword = "",
    String subKeyword = "",
    String itemDescription = "",
    String coverImagePath = "",
    List<String> otherImagePaths = const [],
    int userPrice = 0,
    int priceStart = -100,
    int priceEnd = 100,
    String tradeOption = "",
    bool isPremium = false,
    String location = "",
  })  : _owned_by = ownedBy,
        _main_color = mainColor,
        _sub_color = subColor,
        _category = category,
        _main_keyword = mainKeyword,
        _sub_keyword = subKeyword,
        _item_description = itemDescription,
        _cover_image_path = coverImagePath,
        _other_image_paths = otherImagePaths,
        _user_price = userPrice,
        _price_start = priceStart,
        _price_end = priceEnd,
        _trade_option = tradeOption,
        _is_premium = isPremium,
        _location = location;

  // Getters for accessing private variables
  String get ownedBy => _owned_by;
  Color get mainColor => _main_color;
  Color get subColor => _sub_color;
  String get category => _category;
  String get mainKeyword => _main_keyword;
  String get subKeyword => _sub_keyword;

  String get itemDescription => _item_description;
  String get coverImagePath => _cover_image_path;
  List<String> get otherImagePaths => _other_image_paths;
  int get userPrice => _user_price;
  int get priceStart => _price_start;
  int get priceEnd => _price_end;
  String get tradeOption => _trade_option;
  bool get isPremium => _is_premium;
  String get location => _location;

  // Setters for updating private variables
  set ownedBy(String value) {
    _owned_by = value;
  }

  set mainColor(Color value) {
    _main_color = value;
  }

  set subColor(Color value) {
    _sub_color = value;
  }

  set category(String value) {
    _category = value;
  }

  set mainKeyword(String value) {
    _main_keyword = value;
  }

  set subKeyword(String value) {
    _sub_keyword = value;
  }

  set itemDescription(String value) {
    _item_description = value;
  }

  set coverImagePath(String value) {
    _cover_image_path = value;
  }

  set otherImagePaths(List<String> value) {
    _other_image_paths = value;
  }

  set userPrice(int value) {
    _user_price = value;
  }

  set priceStart(int value) {
    _price_start = value;
  }

  set priceEnd(int value) {
    _price_end = value;
  }

  set tradeOption(String value) {
    _trade_option = value;
  }

  set isPremium(bool value) {
    _is_premium = value;
  }

  set location(String value) {
    _location = value;
  }
}
