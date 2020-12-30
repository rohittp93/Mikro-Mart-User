import 'package:flutter/material.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/item.dart';

enum CartResponseEnum {
  OUT_OF_STOCK,
  PRICE_UPDATED,
  CART_QUANTITY_MORE,
  UNAVAILABLE,
  VALID
}

class CartValidationResponse {
  CartResponseEnum status;
  CartItem cartItem;
  Item currentItem;

  CartValidationResponse(
      {@required this.status,
      @required this.cartItem,
      @required this.currentItem});
}
