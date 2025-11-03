import 'package:flutter/material.dart';
import 'package:rjfruits/res/components/search_enums.dart';

class SearchUiSwithchRepository extends ChangeNotifier {
  SearchUIType selectedNewType = SearchUIType.DeaultSearchSection;

  SearchUIType get selectedType => selectedNewType;

  void switchToType(SearchUIType type) {
    selectedNewType = type;
    notifyListeners();
  }

  void switchToDefaultSection() {
    switchToType(SearchUIType.DeaultSearchSection);
    notifyListeners();
  }
}
