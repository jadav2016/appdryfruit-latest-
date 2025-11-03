import 'package:flutter/material.dart';
import 'package:rjfruits/res/components/enums.dart';

class HomeUiSwithchRepository extends ChangeNotifier {
  bool isLoading = false;
  UIType _selectedType = UIType.DefaultSection;

  UIType get selectedType => _selectedType;

  loading(bool loading){
    isLoading = loading;
    notifyListeners();
  }

  void switchToType(UIType type) {
    _selectedType = type;
    notifyListeners();
  }



  void switchToDefaultSection() {
    switchToType(UIType.DefaultSection);
    notifyListeners();
  }

}
