import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/domain/item/datasource/item_datasource.dart';
import 'package:image_picker/image_picker.dart';

class ItemRepository {
  final ItemDatasource _itemDataSource;

  ItemRepository(this._itemDataSource);

  Future<dynamic> upload_image(UploadType type, String uid, XFile image) async {
    return _itemDataSource.uploadImage(type, uid, image);
  }

  Future<Map<dynamic, dynamic>?> getImageDataFromDatabase(
      String imageUrl) async {
    return _itemDataSource.getImageDataFromDatabase(imageUrl);
  }

  Future<String> register_item(
    String coverImageLocation,
    List<String> otherImagesLocation,
    String categoryId,
    int priceStart,
    int priceEnd,
    String description,
    String ownedBy,
    bool isPremium,
    String mainKeyword,
    String subKeyword,
    String mainColour,
    String subColour,
    String itemLocation,
  ) async {
    return _itemDataSource.createItemOnCallFunction(
        coverImageLocation,
        otherImagesLocation,
        categoryId,
        priceStart,
        priceEnd,
        description,
        ownedBy,
        isPremium,
        mainKeyword,
        subKeyword,
        mainColour,
        subColour,
        itemLocation);
  }
}
