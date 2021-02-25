import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/models/item.dart';

class StoresNotifier with ChangeNotifier {
  List<Store> _storesList = [];
  Store _currentStore;

  List<Store> get categoriesList => _storesList;

  Store get currentCategory=> _currentStore;

  set categoryList(List<Store> categories){
    _storesList = categories;
    notifyListeners();
  }

  set currentItem(Store item){
    _currentStore = item;
    notifyListeners();
  }



  List<Store> getStoreWithCatId(String category) {
    List<Store> _storesOdSelectedCategory = [];

    for(Store store in _storesList){
      if(store.outlet_type!=null && store.outlet_type == category){
        _storesOdSelectedCategory.add(store);
      }
    }

    return _storesOdSelectedCategory;
  }


}