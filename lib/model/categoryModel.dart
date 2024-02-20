class CategoryModel {
  final List<String> _categories = [];
  final List<String> _selected = [];

  List<String> get categories => _categories.toList();
  List<String> get selected => _selected.toList();

  void addcategory(String value) {
    _categories.add(value);
  }

  void addselected(String value) {
    _selected.add(value);
  }

  void clearSelected() {
    _selected.clear();
  }

  void clearcategories() {
    _categories.clear();
  }
}
