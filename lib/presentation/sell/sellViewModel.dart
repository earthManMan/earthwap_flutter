import 'package:firebase_login/domain/login/userService.dart';
import 'package:flutter/material.dart';

// 추가된 import 문
import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/app/util/validateColor_util.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/domain/category/service/category_service.dart';
import 'package:firebase_login/domain/item/service/item_register_service.dart';

class SellViewModel extends ChangeNotifier {
  final UserService _userService;
  final CategoryService _categoryService;
  final ItemRegisterService _itemService;
  final List<String> _selected = [];

  List<String> get selected => _selected.toList();

  SellViewModel(
    this._userService,
    this._itemService,
    this._categoryService,
  );

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory SellViewModel.initialize(UserService user_service,
      ItemRegisterService item_service, CategoryService category) {
    return SellViewModel(user_service, item_service, category);
  }

  Future<void> uploadImage(UploadType type, XFile image) async {
    final result = await _itemService.upload(type, image);

    if (type == UploadType.cover) {
      String url = result['url'] ?? '';
      String uniqueFileName = result['uniqueFileName'] ?? '';
      _itemService.itemModel.coverImagePath = url;
      final data = await _itemService.getCoverAnalysis(uniqueFileName);
      if (data != null) {
        _itemService.itemModel.mainColor =
            hexStringToColor(data!["main_color"].toString());
        _itemService.itemModel.subColor =
            hexStringToColor(data!["sub_color"].toString());
      }
    } else if (type == UploadType.other)
      _itemService.itemModel.otherImagePaths =
          List.from(_itemService.itemModel.otherImagePaths)
            ..add(result.toString());

    notifyListeners();
  }

  Future<String> registerItem(String description, String mainKeyword,
      String subKeyword, int userprice, int priceStart, int priceEnd) async {
    return _itemService.register(_userService.uid.toString(), description,
        mainKeyword, subKeyword, userprice, priceStart, priceEnd);
  }

/*
  Future<bool> getRegisterItem(String id) async {
    final item = ItemService.instance;
    item.addItem(id);
    return true;
  }
*/
  List<String> getCategories() {
    return _categoryService.categories;
  }

  Color getMainColor() {
    return _itemService.itemModel.mainColor;
  }

  Color getSubColor() {
    return _itemService.itemModel.subColor;
  }

  void addselectedCategory(String item) {
    _selected.add(item);
    _itemService.itemModel.category = item;
  }

  void clearselectedCategory() {
    _selected.clear();
    _itemService.itemModel.category = "";
  }

  void clearCoverimage() {
    _itemService.itemModel.coverImagePath = "";
  }

  void clearOtherImage(String url) {
    _itemService.itemModel.otherImagePaths
        .removeWhere((element) => element == url);
  }

  void clearModel() {
    _itemService.clearModel();
  }
}
