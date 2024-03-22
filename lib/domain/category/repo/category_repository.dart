import 'package:firebase_login/domain/category/datasource/category_datasource.dart';

class CategoryRepository {
  final CategoryDataSource _categoryDataSource;

  CategoryRepository(this._categoryDataSource);


  Future<List<dynamic>> getAllCategoriesOnCallFunction(){
    return _categoryDataSource.getAllCategoriesOnCallFunction();
  }
}
