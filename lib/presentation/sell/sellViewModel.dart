import 'package:firebase_login/domain/home/itemService.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/domain/sell/sell_model.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_login/app/config/remote_options.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/domain/category/service/category_service.dart';

class SellViewModel extends ChangeNotifier {
  SellModel _model;
  final UserService _userService;
  final CategoryService _categoryService;
  final List<String> _selected = [];
  SellModel get model => _model;
  List<String> get selected => _selected.toList();
  SellViewModel(
    this._model,
    this._userService,
    this._categoryService,
  );

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory SellViewModel.initialize(UserService service,CategoryService category) {
    final sellModel = SellModel(); // 필요한 초기화 로직을 수행하도록 변경
    final config = RemoteConfigOptions.instance;

    final valueList = config.getSellModelJsonMap();
    sellModel.setKeywordDescription(valueList['keywordDescription']);
    sellModel.setDescriptionHint(valueList['description']);

    return SellViewModel(
      sellModel,
      service,
      category,
    );
  }

  Future<bool> getImageUploadResult(String imageURL) async {
    final api = FirebaseAPI();
    return api.getImageDataFromDatabase(imageURL, this);
  }

  Future<dynamic> uploadImage(UploadType type, String uid, XFile image) async {
    final api = FirebaseAPI();

    return api.uploadImage(type, uid, image);
  }

  Future<String> registerItem() async {
    final api = FirebaseAPI();

    // TODO : 카테고리 List로
    return api.createItemOnCallFunction(
        _model.getcoverImage(),
        _model.getotherImages(),
        selected.first.toString(),
        _model.getPriceStart(),
        _model.getPriceEnd(),
        _model.getdescription(),
        _userService.uid.toString(),
        false,
        _model.getMainKeyword(),
        _model.getSubKeyword(),
        _model.getmain_color().value.toRadixString(16),
        _model.getsub_color().value.toRadixString(16),
        "google"
        //_userService.university.toString(),
        );
  }

  Future<bool> getRegisterItem(String id) async {
    final item = ItemService.instance;
    item.addItem(id);
    return true;
  }

  void clearModel() {
    _model.clearModel();
    _model = SellModel();
    final config = RemoteConfigOptions.instance;

    final valueList = config.getSellModelJsonMap();
    _model.setKeywordDescription(valueList['keywordDescription']);
    _model.setDescriptionHint(valueList['description']);
  }
}
