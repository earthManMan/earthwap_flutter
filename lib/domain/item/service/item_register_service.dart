import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/domain/item/model/item_model.dart';
import 'package:firebase_login/domain/item/repo/item_repository.dart';
import 'package:image_picker/image_picker.dart';

class ItemRegisterService {
  final ItemRepository _itemRepository;

  ItemModel _itemModel;

  ItemRegisterService(this._itemRepository, this._itemModel);

  ItemModel get itemModel => _itemModel;

  set itemModel(ItemModel itemmodel) {
    _itemModel = itemmodel;
  }

  Future<dynamic> upload(UploadType type, XFile imge) async {
    return _itemRepository.upload_image(type, _itemModel.ownedBy, imge);
  }

  Future<Map<dynamic, dynamic>?> getCoverAnalysis(String imageUrl) async {
    return _itemRepository.getImageDataFromDatabase(imageUrl);
  }

  Future<String> register(String ownedBy, String description, String mainKeyword,
      String subKeyword, int userprice, int priceStart, int priceEnd) async {
    _itemModel.itemDescription = description;
    _itemModel.mainKeyword = mainKeyword;
    _itemModel.subKeyword = subKeyword;
    _itemModel.userPrice = userprice;
    _itemModel.priceStart = priceStart;
    _itemModel.priceEnd = priceEnd;
    _itemModel.ownedBy = ownedBy;

    return _itemRepository.register_item(
        _itemModel.coverImagePath,
        _itemModel.otherImagePaths,
        _itemModel.category,
        _itemModel.priceStart,
        _itemModel.priceEnd,
        _itemModel.itemDescription,
        _itemModel.ownedBy,
        _itemModel.isPremium,
        _itemModel.mainKeyword,
        _itemModel.subKeyword,
        _itemModel.mainColor.value.toRadixString(16),
        _itemModel.subColor.value.toRadixString(16),
        "google"); // TODO : location 정보 추가되어야 함.
  }

  void clearModel() {
    _itemModel = ItemModel();
  }
}
