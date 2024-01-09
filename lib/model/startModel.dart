class StartModel {
  List<String> _infoImg = [];
  List<String> _infoTitle =
      []; // = ['새로운 차원의 쇼핑', '지갑은 넣어두세요', '현명한 US의 EARTH'];

  List<String> _infoSubTitle = [];
  /*[
    '무한한 SWAP SPACE\nEARTHWAP의 새로운 조종사',
    '너와 나의 물물교환 플랫폼\n새로운 물건의 주인',
    '환경까지 생각하는 현명한 우리\nEARTH를 위한 US의 쇼핑 방식'
  ];*/

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
