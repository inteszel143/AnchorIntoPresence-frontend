import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier {
  String _name = '';
  String _image = '';

  String get name => _name;

  String get image => _image;

  void setUser(String name, String image) {
    _name = name;
    _image = image;
    notifyListeners();
  }

  void updateUserProfile(String newName, String newImage) {
    _name = newName;
    _image = newImage;
    notifyListeners();
  }

}