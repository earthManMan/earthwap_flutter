import 'package:flutter/material.dart';
import 'package:firebase_login/model/startModel.dart';
import 'package:firebase_login/application_options.dart';

class StartViewModel extends ChangeNotifier {
  final StartModel _model;

  StartViewModel(this._model);

  StartModel get model => _model;

  factory StartViewModel.initialize() {
    final startModel = StartModel();

    final config = RemoteConfigService.instance;
    List<String> titles = [];
    List<String> subtitles = [];
    List<String> images = [];

    final valueList = config.getStartModelJsonMap();
    for (final value in valueList) {
      titles.add(value["infoTitle"].toString());
      subtitles.add(value["infoSubTitle"].toString());
    }

    images.add(config.getimages()["start_info_1"]);
    images.add(config.getimages()["start_info_2"]);
    images.add(config.getimages()["start_info_3"]);

    startModel.setTitle(titles);
    startModel.setSubTitle(subtitles);
    startModel.setImage(images);

    return StartViewModel(startModel);
  }

  void clearModel() {
    _model.clearModel();
  }
}
