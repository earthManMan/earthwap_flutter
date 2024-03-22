import 'package:firebase_login/domain/category/repo/category_repository.dart';

class CategoryService {
  final CategoryRepository _categoryRepository;

  List<String> _categories = [];

  CategoryService(this._categoryRepository) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    if (_categories.isEmpty) {
      final result = await _categoryRepository.getAllCategoriesOnCallFunction();
      for (final category in result) {
        _categories.add(category['id'].toString());
      }
    }
  }
}
