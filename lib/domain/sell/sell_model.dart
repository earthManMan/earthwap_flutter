import 'package:flutter/material.dart';

class SellModel {
  String _KeywordDescription = "";
  String _descriptionHint = "";

  String _coverImage = "";
  List<String> _otherImages = [];
  String _mainKeyword = "";
  String _subKeyword = "";

  int _userPrice = 0;
  int _price_start = -100;
  int _price_end = 100;

  String _description = "";
  String _trade_option = "";
  String _owned_by = "";
  bool _is_premium = false;
  Color _main_color = Colors.blue;
  Color _sub_color = Colors.amber;

  void setKeywordDescription(String keywordDescription) {
    _KeywordDescription = keywordDescription;
  }

  String getKeywordDescription() {
    return _KeywordDescription;
  }

  String getDescriptionHint() {
    return _descriptionHint;
  }

  void setDescriptionHint(String descriptionHint) {
    _descriptionHint = descriptionHint;
  }

  void initializeModel() {
    _coverImage = "";
    _otherImages = [];
    _mainKeyword = "";
    _subKeyword = "";
    _price_start = -100;
    _price_end = 100;
    _userPrice = 0;
    _description = "";
    _trade_option = "";
    _owned_by = "";
    _is_premium = false;
    _main_color = Colors.blue;
    _sub_color = Colors.amber;
  }

  void resetModel() {
    _coverImage = "";
    _otherImages = [];
    _mainKeyword = "";
    _subKeyword = "";
    _price_start = -100;
    _price_end = 100;
    _userPrice = 0;
    _description = "";
    _trade_option = "";
    _owned_by = "";
    _is_premium = false;
    _main_color = Colors.blue;
    _sub_color = Colors.amber;
  }

  void setcoverImage(String value) {
    _coverImage = value;
  }

  String getcoverImage() {
    return _coverImage;
  }

  List<String> getotherImages() {
    return _otherImages;
  }

  void addotherImage(String value) {
    _otherImages.add(value);
  }

  void setMainKeyword(String value) {
    _mainKeyword = value;
  }

  void setSubKeyword(String value) {
    _subKeyword = value;
  }

  String getMainKeyword() {
    return _mainKeyword;
  }

  String getSubKeyword() {
    return _subKeyword;
  }

  void setprice_start(int value) {
    _price_start = value;
  }

  void setprice_end(int value) {
    _price_end = value;
  }

  int getPriceStart() {
    return _price_start;
  }

  int getPriceEnd() {
    return _price_end;
  }

  void setUserPrice(int value) {
    _userPrice = value;
  }

  int getUserPrice() {
    return _userPrice;
  }

  void setdescription(String value) {
    _description = value;
  }

  String getdescription() {
    return _description;
  }

  void settrade_option(String value) {
    _trade_option = value;
  }

  void setowned_by(String value) {
    _owned_by = value;
  }

  void setpremium(bool value) {
    _is_premium = value;
  }

  void setmain_color(Color color) {
    _main_color = color;
  }

  Color getmain_color() {
    return _main_color;
  }

  void setsub_color(Color color) {
    _sub_color = color;
  }

  Color getsub_color() {
    return _sub_color;
  }

  void clearModel() {
    _coverImage = "";
    _otherImages.clear();
    _mainKeyword = "";
    _subKeyword = "";

    _userPrice = 0;
    _price_start = -100;
    _price_end = 100;

    _description = "";
    _trade_option = "";
    _owned_by = "";
    _is_premium = false;
    _main_color = Colors.blue;
    _sub_color = Colors.amber;
  }
}
