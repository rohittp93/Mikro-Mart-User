
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:userapp/core/models/item.dart';

class ItemNotifier with ChangeNotifier {
  List<Item> _offerItemList = [];
  Item _currentItem;

  UnmodifiableListView<Item> get offerItemList => UnmodifiableListView(_offerItemList);

  Item get currentItem => _currentItem;

  set offerList(List<Item> itemList){
    _offerItemList = itemList;
    notifyListeners();
  }

  set currentItem(Item item){
    _currentItem = item;
    notifyListeners();
  }

}