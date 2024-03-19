class StartModel {
  List<String> _infoImg = [];
  List<String> _infoTitle = [];

  List<String> _infoSubTitle = [];

  List<String> getImage() {
    return _infoImg;
  }

  List<String> getTitle() {
    return _infoTitle;
  }

  List<String> getSubTitle() {
    return _infoSubTitle;
  }

  void setImage(List<String> images) {
    _infoImg = images;
  }

  void setTitle(List<String> titles) {
    _infoTitle = titles;
  }

  void setSubTitle(List<String> subTitles) {
    _infoSubTitle = subTitles;
  }

  void clearModel() {}
}
