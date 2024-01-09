import 'package:firebase_login/service/itemService.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/sellModel.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/model/categoryModel.dart';
import 'package:firebase_login/application_options.dart';

class SellViewModel extends ChangeNotifier {
  SellModel _model;
  final UserService _userService;
  final CategoryModel _categoryModel = CategoryModel();

  SellModel get model => _model;
  CategoryModel get categorymodel => _categoryModel;

  SellViewModel(
    this._model,
    this._userService,
  );

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory SellViewModel.initialize(UserService service) {
    final sellModel = SellModel(); // 필요한 초기화 로직을 수행하도록 변경
    final config = RemoteConfigService.instance;

    final valueList = config.getSellModelJsonMap();
    sellModel.setKeywordDescription(valueList['keywordDescription']);
    sellModel.setDescriptionHint(valueList['description']);

    return SellViewModel(
      sellModel,
      service,
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
      _categoryModel.selected.first.toString(),
      _model.getPriceStart(),
      _model.getPriceEnd(),
      _model.getdescription(),
      _userService.uid.toString(),
      false,
      _model.getMainKeyword(),
      _model.getSubKeyword(),
      _model.getmain_color().value.toRadixString(16),
      _model.getsub_color().value.toRadixString(16),
      _userService.university.toString(),
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
    final config = RemoteConfigService.instance;

    final valueList = config.getSellModelJsonMap();
    _model.setKeywordDescription(valueList['keywordDescription']);
    _model.setDescriptionHint(valueList['description']);
  }
}
