// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class CartItem extends DataClass implements Insertable<CartItem> {
  final String itemId;
  final String cartItemId;
  final String itemName;
  final String itemImage;
  final String itemQuantity;
  final String outletId;
  final double itemPrice;
  final double cartPrice;
  final int cartQuantity;
  final int quantityInStock;
  final int maxQuantity;
  CartItem(
      {@required this.itemId,
      @required this.cartItemId,
      @required this.itemName,
      @required this.itemImage,
      @required this.itemQuantity,
      @required this.outletId,
      @required this.itemPrice,
      @required this.cartPrice,
      @required this.cartQuantity,
      @required this.quantityInStock,
      @required this.maxQuantity});
  factory CartItem.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final intType = db.typeSystem.forDartType<int>();
    return CartItem(
      itemId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}item_id']),
      cartItemId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}cart_item_id']),
      itemName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_name']),
      itemImage: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_image']),
      itemQuantity: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_quantity']),
      outletId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}outlet_id']),
      itemPrice: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_price']),
      cartPrice: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}cart_price']),
      cartQuantity: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}cart_quantity']),
      quantityInStock: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}quantity_in_stock']),
      maxQuantity: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}max_quantity']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    if (!nullToAbsent || cartItemId != null) {
      map['cart_item_id'] = Variable<String>(cartItemId);
    }
    if (!nullToAbsent || itemName != null) {
      map['item_name'] = Variable<String>(itemName);
    }
    if (!nullToAbsent || itemImage != null) {
      map['item_image'] = Variable<String>(itemImage);
    }
    if (!nullToAbsent || itemQuantity != null) {
      map['item_quantity'] = Variable<String>(itemQuantity);
    }
    if (!nullToAbsent || outletId != null) {
      map['outlet_id'] = Variable<String>(outletId);
    }
    if (!nullToAbsent || itemPrice != null) {
      map['item_price'] = Variable<double>(itemPrice);
    }
    if (!nullToAbsent || cartPrice != null) {
      map['cart_price'] = Variable<double>(cartPrice);
    }
    if (!nullToAbsent || cartQuantity != null) {
      map['cart_quantity'] = Variable<int>(cartQuantity);
    }
    if (!nullToAbsent || quantityInStock != null) {
      map['quantity_in_stock'] = Variable<int>(quantityInStock);
    }
    if (!nullToAbsent || maxQuantity != null) {
      map['max_quantity'] = Variable<int>(maxQuantity);
    }
    return map;
  }

  CartItemsCompanion toCompanion(bool nullToAbsent) {
    return CartItemsCompanion(
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      cartItemId: cartItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartItemId),
      itemName: itemName == null && nullToAbsent
          ? const Value.absent()
          : Value(itemName),
      itemImage: itemImage == null && nullToAbsent
          ? const Value.absent()
          : Value(itemImage),
      itemQuantity: itemQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(itemQuantity),
      outletId: outletId == null && nullToAbsent
          ? const Value.absent()
          : Value(outletId),
      itemPrice: itemPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(itemPrice),
      cartPrice: cartPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(cartPrice),
      cartQuantity: cartQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(cartQuantity),
      quantityInStock: quantityInStock == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityInStock),
      maxQuantity: maxQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(maxQuantity),
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return CartItem(
      itemId: serializer.fromJson<String>(json['itemId']),
      cartItemId: serializer.fromJson<String>(json['cartItemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemImage: serializer.fromJson<String>(json['itemImage']),
      itemQuantity: serializer.fromJson<String>(json['itemQuantity']),
      outletId: serializer.fromJson<String>(json['outletId']),
      itemPrice: serializer.fromJson<double>(json['itemPrice']),
      cartPrice: serializer.fromJson<double>(json['cartPrice']),
      cartQuantity: serializer.fromJson<int>(json['cartQuantity']),
      quantityInStock: serializer.fromJson<int>(json['quantityInStock']),
      maxQuantity: serializer.fromJson<int>(json['maxQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'cartItemId': serializer.toJson<String>(cartItemId),
      'itemName': serializer.toJson<String>(itemName),
      'itemImage': serializer.toJson<String>(itemImage),
      'itemQuantity': serializer.toJson<String>(itemQuantity),
      'outletId': serializer.toJson<String>(outletId),
      'itemPrice': serializer.toJson<double>(itemPrice),
      'cartPrice': serializer.toJson<double>(cartPrice),
      'cartQuantity': serializer.toJson<int>(cartQuantity),
      'quantityInStock': serializer.toJson<int>(quantityInStock),
      'maxQuantity': serializer.toJson<int>(maxQuantity),
    };
  }

  CartItem copyWith(
          {String itemId,
          String cartItemId,
          String itemName,
          String itemImage,
          String itemQuantity,
          String outletId,
          double itemPrice,
          double cartPrice,
          int cartQuantity,
          int quantityInStock,
          int maxQuantity}) =>
      CartItem(
        itemId: itemId ?? this.itemId,
        cartItemId: cartItemId ?? this.cartItemId,
        itemName: itemName ?? this.itemName,
        itemImage: itemImage ?? this.itemImage,
        itemQuantity: itemQuantity ?? this.itemQuantity,
        outletId: outletId ?? this.outletId,
        itemPrice: itemPrice ?? this.itemPrice,
        cartPrice: cartPrice ?? this.cartPrice,
        cartQuantity: cartQuantity ?? this.cartQuantity,
        quantityInStock: quantityInStock ?? this.quantityInStock,
        maxQuantity: maxQuantity ?? this.maxQuantity,
      );
  @override
  String toString() {
    return (StringBuffer('CartItem(')
          ..write('itemId: $itemId, ')
          ..write('cartItemId: $cartItemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImage: $itemImage, ')
          ..write('itemQuantity: $itemQuantity, ')
          ..write('outletId: $outletId, ')
          ..write('itemPrice: $itemPrice, ')
          ..write('cartPrice: $cartPrice, ')
          ..write('cartQuantity: $cartQuantity, ')
          ..write('quantityInStock: $quantityInStock, ')
          ..write('maxQuantity: $maxQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      itemId.hashCode,
      $mrjc(
          cartItemId.hashCode,
          $mrjc(
              itemName.hashCode,
              $mrjc(
                  itemImage.hashCode,
                  $mrjc(
                      itemQuantity.hashCode,
                      $mrjc(
                          outletId.hashCode,
                          $mrjc(
                              itemPrice.hashCode,
                              $mrjc(
                                  cartPrice.hashCode,
                                  $mrjc(
                                      cartQuantity.hashCode,
                                      $mrjc(quantityInStock.hashCode,
                                          maxQuantity.hashCode)))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.itemId == this.itemId &&
          other.cartItemId == this.cartItemId &&
          other.itemName == this.itemName &&
          other.itemImage == this.itemImage &&
          other.itemQuantity == this.itemQuantity &&
          other.outletId == this.outletId &&
          other.itemPrice == this.itemPrice &&
          other.cartPrice == this.cartPrice &&
          other.cartQuantity == this.cartQuantity &&
          other.quantityInStock == this.quantityInStock &&
          other.maxQuantity == this.maxQuantity);
}

class CartItemsCompanion extends UpdateCompanion<CartItem> {
  final Value<String> itemId;
  final Value<String> cartItemId;
  final Value<String> itemName;
  final Value<String> itemImage;
  final Value<String> itemQuantity;
  final Value<String> outletId;
  final Value<double> itemPrice;
  final Value<double> cartPrice;
  final Value<int> cartQuantity;
  final Value<int> quantityInStock;
  final Value<int> maxQuantity;
  const CartItemsCompanion({
    this.itemId = const Value.absent(),
    this.cartItemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemImage = const Value.absent(),
    this.itemQuantity = const Value.absent(),
    this.outletId = const Value.absent(),
    this.itemPrice = const Value.absent(),
    this.cartPrice = const Value.absent(),
    this.cartQuantity = const Value.absent(),
    this.quantityInStock = const Value.absent(),
    this.maxQuantity = const Value.absent(),
  });
  CartItemsCompanion.insert({
    @required String itemId,
    @required String cartItemId,
    @required String itemName,
    @required String itemImage,
    @required String itemQuantity,
    @required String outletId,
    @required double itemPrice,
    @required double cartPrice,
    @required int cartQuantity,
    @required int quantityInStock,
    @required int maxQuantity,
  })  : itemId = Value(itemId),
        cartItemId = Value(cartItemId),
        itemName = Value(itemName),
        itemImage = Value(itemImage),
        itemQuantity = Value(itemQuantity),
        outletId = Value(outletId),
        itemPrice = Value(itemPrice),
        cartPrice = Value(cartPrice),
        cartQuantity = Value(cartQuantity),
        quantityInStock = Value(quantityInStock),
        maxQuantity = Value(maxQuantity);
  static Insertable<CartItem> custom({
    Expression<String> itemId,
    Expression<String> cartItemId,
    Expression<String> itemName,
    Expression<String> itemImage,
    Expression<String> itemQuantity,
    Expression<String> outletId,
    Expression<double> itemPrice,
    Expression<double> cartPrice,
    Expression<int> cartQuantity,
    Expression<int> quantityInStock,
    Expression<int> maxQuantity,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (cartItemId != null) 'cart_item_id': cartItemId,
      if (itemName != null) 'item_name': itemName,
      if (itemImage != null) 'item_image': itemImage,
      if (itemQuantity != null) 'item_quantity': itemQuantity,
      if (outletId != null) 'outlet_id': outletId,
      if (itemPrice != null) 'item_price': itemPrice,
      if (cartPrice != null) 'cart_price': cartPrice,
      if (cartQuantity != null) 'cart_quantity': cartQuantity,
      if (quantityInStock != null) 'quantity_in_stock': quantityInStock,
      if (maxQuantity != null) 'max_quantity': maxQuantity,
    });
  }

  CartItemsCompanion copyWith(
      {Value<String> itemId,
      Value<String> cartItemId,
      Value<String> itemName,
      Value<String> itemImage,
      Value<String> itemQuantity,
      Value<String> outletId,
      Value<double> itemPrice,
      Value<double> cartPrice,
      Value<int> cartQuantity,
      Value<int> quantityInStock,
      Value<int> maxQuantity}) {
    return CartItemsCompanion(
      itemId: itemId ?? this.itemId,
      cartItemId: cartItemId ?? this.cartItemId,
      itemName: itemName ?? this.itemName,
      itemImage: itemImage ?? this.itemImage,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      outletId: outletId ?? this.outletId,
      itemPrice: itemPrice ?? this.itemPrice,
      cartPrice: cartPrice ?? this.cartPrice,
      cartQuantity: cartQuantity ?? this.cartQuantity,
      quantityInStock: quantityInStock ?? this.quantityInStock,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (cartItemId.present) {
      map['cart_item_id'] = Variable<String>(cartItemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemImage.present) {
      map['item_image'] = Variable<String>(itemImage.value);
    }
    if (itemQuantity.present) {
      map['item_quantity'] = Variable<String>(itemQuantity.value);
    }
    if (outletId.present) {
      map['outlet_id'] = Variable<String>(outletId.value);
    }
    if (itemPrice.present) {
      map['item_price'] = Variable<double>(itemPrice.value);
    }
    if (cartPrice.present) {
      map['cart_price'] = Variable<double>(cartPrice.value);
    }
    if (cartQuantity.present) {
      map['cart_quantity'] = Variable<int>(cartQuantity.value);
    }
    if (quantityInStock.present) {
      map['quantity_in_stock'] = Variable<int>(quantityInStock.value);
    }
    if (maxQuantity.present) {
      map['max_quantity'] = Variable<int>(maxQuantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('cartItemId: $cartItemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImage: $itemImage, ')
          ..write('itemQuantity: $itemQuantity, ')
          ..write('outletId: $outletId, ')
          ..write('itemPrice: $itemPrice, ')
          ..write('cartPrice: $cartPrice, ')
          ..write('cartQuantity: $cartQuantity, ')
          ..write('quantityInStock: $quantityInStock, ')
          ..write('maxQuantity: $maxQuantity')
          ..write(')'))
        .toString();
  }
}

class $CartItemsTable extends CartItems
    with TableInfo<$CartItemsTable, CartItem> {
  final GeneratedDatabase _db;
  final String _alias;
  $CartItemsTable(this._db, [this._alias]);
  final VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  GeneratedTextColumn _itemId;
  @override
  GeneratedTextColumn get itemId => _itemId ??= _constructItemId();
  GeneratedTextColumn _constructItemId() {
    return GeneratedTextColumn(
      'item_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _cartItemIdMeta = const VerificationMeta('cartItemId');
  GeneratedTextColumn _cartItemId;
  @override
  GeneratedTextColumn get cartItemId => _cartItemId ??= _constructCartItemId();
  GeneratedTextColumn _constructCartItemId() {
    return GeneratedTextColumn(
      'cart_item_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _itemNameMeta = const VerificationMeta('itemName');
  GeneratedTextColumn _itemName;
  @override
  GeneratedTextColumn get itemName => _itemName ??= _constructItemName();
  GeneratedTextColumn _constructItemName() {
    return GeneratedTextColumn(
      'item_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _itemImageMeta = const VerificationMeta('itemImage');
  GeneratedTextColumn _itemImage;
  @override
  GeneratedTextColumn get itemImage => _itemImage ??= _constructItemImage();
  GeneratedTextColumn _constructItemImage() {
    return GeneratedTextColumn(
      'item_image',
      $tableName,
      false,
    );
  }

  final VerificationMeta _itemQuantityMeta =
      const VerificationMeta('itemQuantity');
  GeneratedTextColumn _itemQuantity;
  @override
  GeneratedTextColumn get itemQuantity =>
      _itemQuantity ??= _constructItemQuantity();
  GeneratedTextColumn _constructItemQuantity() {
    return GeneratedTextColumn(
      'item_quantity',
      $tableName,
      false,
    );
  }

  final VerificationMeta _outletIdMeta = const VerificationMeta('outletId');
  GeneratedTextColumn _outletId;
  @override
  GeneratedTextColumn get outletId => _outletId ??= _constructOutletId();
  GeneratedTextColumn _constructOutletId() {
    return GeneratedTextColumn(
      'outlet_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _itemPriceMeta = const VerificationMeta('itemPrice');
  GeneratedRealColumn _itemPrice;
  @override
  GeneratedRealColumn get itemPrice => _itemPrice ??= _constructItemPrice();
  GeneratedRealColumn _constructItemPrice() {
    return GeneratedRealColumn(
      'item_price',
      $tableName,
      false,
    );
  }

  final VerificationMeta _cartPriceMeta = const VerificationMeta('cartPrice');
  GeneratedRealColumn _cartPrice;
  @override
  GeneratedRealColumn get cartPrice => _cartPrice ??= _constructCartPrice();
  GeneratedRealColumn _constructCartPrice() {
    return GeneratedRealColumn(
      'cart_price',
      $tableName,
      false,
    );
  }

  final VerificationMeta _cartQuantityMeta =
      const VerificationMeta('cartQuantity');
  GeneratedIntColumn _cartQuantity;
  @override
  GeneratedIntColumn get cartQuantity =>
      _cartQuantity ??= _constructCartQuantity();
  GeneratedIntColumn _constructCartQuantity() {
    return GeneratedIntColumn(
      'cart_quantity',
      $tableName,
      false,
    );
  }

  final VerificationMeta _quantityInStockMeta =
      const VerificationMeta('quantityInStock');
  GeneratedIntColumn _quantityInStock;
  @override
  GeneratedIntColumn get quantityInStock =>
      _quantityInStock ??= _constructQuantityInStock();
  GeneratedIntColumn _constructQuantityInStock() {
    return GeneratedIntColumn(
      'quantity_in_stock',
      $tableName,
      false,
    );
  }

  final VerificationMeta _maxQuantityMeta =
      const VerificationMeta('maxQuantity');
  GeneratedIntColumn _maxQuantity;
  @override
  GeneratedIntColumn get maxQuantity =>
      _maxQuantity ??= _constructMaxQuantity();
  GeneratedIntColumn _constructMaxQuantity() {
    return GeneratedIntColumn(
      'max_quantity',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        cartItemId,
        itemName,
        itemImage,
        itemQuantity,
        outletId,
        itemPrice,
        cartPrice,
        cartQuantity,
        quantityInStock,
        maxQuantity
      ];
  @override
  $CartItemsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'cart_items';
  @override
  final String actualTableName = 'cart_items';
  @override
  VerificationContext validateIntegrity(Insertable<CartItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id'], _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('cart_item_id')) {
      context.handle(
          _cartItemIdMeta,
          cartItemId.isAcceptableOrUnknown(
              data['cart_item_id'], _cartItemIdMeta));
    } else if (isInserting) {
      context.missing(_cartItemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name'], _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_image')) {
      context.handle(_itemImageMeta,
          itemImage.isAcceptableOrUnknown(data['item_image'], _itemImageMeta));
    } else if (isInserting) {
      context.missing(_itemImageMeta);
    }
    if (data.containsKey('item_quantity')) {
      context.handle(
          _itemQuantityMeta,
          itemQuantity.isAcceptableOrUnknown(
              data['item_quantity'], _itemQuantityMeta));
    } else if (isInserting) {
      context.missing(_itemQuantityMeta);
    }
    if (data.containsKey('outlet_id')) {
      context.handle(_outletIdMeta,
          outletId.isAcceptableOrUnknown(data['outlet_id'], _outletIdMeta));
    } else if (isInserting) {
      context.missing(_outletIdMeta);
    }
    if (data.containsKey('item_price')) {
      context.handle(_itemPriceMeta,
          itemPrice.isAcceptableOrUnknown(data['item_price'], _itemPriceMeta));
    } else if (isInserting) {
      context.missing(_itemPriceMeta);
    }
    if (data.containsKey('cart_price')) {
      context.handle(_cartPriceMeta,
          cartPrice.isAcceptableOrUnknown(data['cart_price'], _cartPriceMeta));
    } else if (isInserting) {
      context.missing(_cartPriceMeta);
    }
    if (data.containsKey('cart_quantity')) {
      context.handle(
          _cartQuantityMeta,
          cartQuantity.isAcceptableOrUnknown(
              data['cart_quantity'], _cartQuantityMeta));
    } else if (isInserting) {
      context.missing(_cartQuantityMeta);
    }
    if (data.containsKey('quantity_in_stock')) {
      context.handle(
          _quantityInStockMeta,
          quantityInStock.isAcceptableOrUnknown(
              data['quantity_in_stock'], _quantityInStockMeta));
    } else if (isInserting) {
      context.missing(_quantityInStockMeta);
    }
    if (data.containsKey('max_quantity')) {
      context.handle(
          _maxQuantityMeta,
          maxQuantity.isAcceptableOrUnknown(
              data['max_quantity'], _maxQuantityMeta));
    } else if (isInserting) {
      context.missing(_maxQuantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cartItemId};
  @override
  CartItem map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return CartItem.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $CartItemsTable createAlias(String alias) {
    return $CartItemsTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $CartItemsTable _cartItems;
  $CartItemsTable get cartItems => _cartItems ??= $CartItemsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cartItems];
}
