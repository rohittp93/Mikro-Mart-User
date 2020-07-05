import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';

class CategoriesNotifier with ChangeNotifier {
  List<Category> _categoriesList = [];
  Category _currentCategory;

  UnmodifiableListView<Category> get categoriesList => UnmodifiableListView(_categoriesList);

  Category get currentCategory=> _currentCategory;

  set categoryList(List<Category> categories){
    _categoriesList = categories;
    notifyListeners();
  }

  set currentItem(Category item){
    _currentCategory = item;
    notifyListeners();
  }
}