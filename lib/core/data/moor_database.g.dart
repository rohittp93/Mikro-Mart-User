// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class User extends DataClass implements Insertable<User> {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool phoneValidated;
  User(
      {@required this.uid,
      @required this.name,
      @required this.email,
      @required this.phone,
      @required this.phoneValidated});
  factory User.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return User(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      email:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}email']),
      phone:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}phone']),
      phoneValidated: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}phone_validated']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || phoneValidated != null) {
      map['phone_validated'] = Variable<bool>(phoneValidated);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      phoneValidated: phoneValidated == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneValidated),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return User(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      phoneValidated: serializer.fromJson<bool>(json['phoneValidated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'phoneValidated': serializer.toJson<bool>(phoneValidated),
    };
  }

  User copyWith(
          {String uid,
          String name,
          String email,
          String phone,
          bool phoneValidated}) =>
      User(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        phoneValidated: phoneValidated ?? this.phoneValidated,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('phoneValidated: $phoneValidated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      uid.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(email.hashCode,
              $mrjc(phone.hashCode, phoneValidated.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is User &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.phoneValidated == this.phoneValidated);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> uid;
  final Value<String> name;
  final Value<String> email;
  final Value<String> phone;
  final Value<bool> phoneValidated;
  const UsersCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.phoneValidated = const Value.absent(),
  });
  UsersCompanion.insert({
    @required String uid,
    @required String name,
    @required String email,
    @required String phone,
    @required bool phoneValidated,
  })  : uid = Value(uid),
        name = Value(name),
        email = Value(email),
        phone = Value(phone),
        phoneValidated = Value(phoneValidated);
  static Insertable<User> custom({
    Expression<String> uid,
    Expression<String> name,
    Expression<String> email,
    Expression<String> phone,
    Expression<bool> phoneValidated,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (phoneValidated != null) 'phone_validated': phoneValidated,
    });
  }

  UsersCompanion copyWith(
      {Value<String> uid,
      Value<String> name,
      Value<String> email,
      Value<String> phone,
      Value<bool> phoneValidated}) {
    return UsersCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneValidated: phoneValidated ?? this.phoneValidated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (phoneValidated.present) {
      map['phone_validated'] = Variable<bool>(phoneValidated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('phoneValidated: $phoneValidated')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  final GeneratedDatabase _db;
  final String _alias;
  $UsersTable(this._db, [this._alias]);
  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  GeneratedTextColumn _uid;
  @override
  GeneratedTextColumn get uid => _uid ??= _constructUid();
  GeneratedTextColumn _constructUid() {
    return GeneratedTextColumn(
      'uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _emailMeta = const VerificationMeta('email');
  GeneratedTextColumn _email;
  @override
  GeneratedTextColumn get email => _email ??= _constructEmail();
  GeneratedTextColumn _constructEmail() {
    return GeneratedTextColumn(
      'email',
      $tableName,
      false,
    );
  }

  final VerificationMeta _phoneMeta = const VerificationMeta('phone');
  GeneratedTextColumn _phone;
  @override
  GeneratedTextColumn get phone => _phone ??= _constructPhone();
  GeneratedTextColumn _constructPhone() {
    return GeneratedTextColumn(
      'phone',
      $tableName,
      false,
    );
  }

  final VerificationMeta _phoneValidatedMeta =
      const VerificationMeta('phoneValidated');
  GeneratedBoolColumn _phoneValidated;
  @override
  GeneratedBoolColumn get phoneValidated =>
      _phoneValidated ??= _constructPhoneValidated();
  GeneratedBoolColumn _constructPhoneValidated() {
    return GeneratedBoolColumn(
      'phone_validated',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [uid, name, email, phone, phoneValidated];
  @override
  $UsersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'users';
  @override
  final String actualTableName = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email'], _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone'], _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('phone_validated')) {
      context.handle(
          _phoneValidatedMeta,
          phoneValidated.isAcceptableOrUnknown(
              data['phone_validated'], _phoneValidatedMeta));
    } else if (isInserting) {
      context.missing(_phoneValidatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  User map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return User.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(_db, alias);
  }
}

class CartItem extends DataClass implements Insertable<CartItem> {
  final String itemId;
  final String itemName;
  final String itemImage;
  final int itemQuantity;
  CartItem(
      {@required this.itemId,
      @required this.itemName,
      @required this.itemImage,
      @required this.itemQuantity});
  factory CartItem.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return CartItem(
      itemId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}item_id']),
      itemName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_name']),
      itemImage: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_image']),
      itemQuantity: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}item_quantity']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    if (!nullToAbsent || itemName != null) {
      map['item_name'] = Variable<String>(itemName);
    }
    if (!nullToAbsent || itemImage != null) {
      map['item_image'] = Variable<String>(itemImage);
    }
    if (!nullToAbsent || itemQuantity != null) {
      map['item_quantity'] = Variable<int>(itemQuantity);
    }
    return map;
  }

  CartItemsCompanion toCompanion(bool nullToAbsent) {
    return CartItemsCompanion(
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      itemName: itemName == null && nullToAbsent
          ? const Value.absent()
          : Value(itemName),
      itemImage: itemImage == null && nullToAbsent
          ? const Value.absent()
          : Value(itemImage),
      itemQuantity: itemQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(itemQuantity),
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return CartItem(
      itemId: serializer.fromJson<String>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemImage: serializer.fromJson<String>(json['itemImage']),
      itemQuantity: serializer.fromJson<int>(json['itemQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'itemImage': serializer.toJson<String>(itemImage),
      'itemQuantity': serializer.toJson<int>(itemQuantity),
    };
  }

  CartItem copyWith(
          {String itemId,
          String itemName,
          String itemImage,
          int itemQuantity}) =>
      CartItem(
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemImage: itemImage ?? this.itemImage,
        itemQuantity: itemQuantity ?? this.itemQuantity,
      );
  @override
  String toString() {
    return (StringBuffer('CartItem(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImage: $itemImage, ')
          ..write('itemQuantity: $itemQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      itemId.hashCode,
      $mrjc(itemName.hashCode,
          $mrjc(itemImage.hashCode, itemQuantity.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.itemImage == this.itemImage &&
          other.itemQuantity == this.itemQuantity);
}

class CartItemsCompanion extends UpdateCompanion<CartItem> {
  final Value<String> itemId;
  final Value<String> itemName;
  final Value<String> itemImage;
  final Value<int> itemQuantity;
  const CartItemsCompanion({
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemImage = const Value.absent(),
    this.itemQuantity = const Value.absent(),
  });
  CartItemsCompanion.insert({
    @required String itemId,
    @required String itemName,
    @required String itemImage,
    @required int itemQuantity,
  })  : itemId = Value(itemId),
        itemName = Value(itemName),
        itemImage = Value(itemImage),
        itemQuantity = Value(itemQuantity);
  static Insertable<CartItem> custom({
    Expression<String> itemId,
    Expression<String> itemName,
    Expression<String> itemImage,
    Expression<int> itemQuantity,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (itemImage != null) 'item_image': itemImage,
      if (itemQuantity != null) 'item_quantity': itemQuantity,
    });
  }

  CartItemsCompanion copyWith(
      {Value<String> itemId,
      Value<String> itemName,
      Value<String> itemImage,
      Value<int> itemQuantity}) {
    return CartItemsCompanion(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemImage: itemImage ?? this.itemImage,
      itemQuantity: itemQuantity ?? this.itemQuantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemImage.present) {
      map['item_image'] = Variable<String>(itemImage.value);
    }
    if (itemQuantity.present) {
      map['item_quantity'] = Variable<int>(itemQuantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImage: $itemImage, ')
          ..write('itemQuantity: $itemQuantity')
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
  GeneratedIntColumn _itemQuantity;
  @override
  GeneratedIntColumn get itemQuantity =>
      _itemQuantity ??= _constructItemQuantity();
  GeneratedIntColumn _constructItemQuantity() {
    return GeneratedIntColumn(
      'item_quantity',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [itemId, itemName, itemImage, itemQuantity];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
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
  $UsersTable _users;
  $UsersTable get users => _users ??= $UsersTable(this);
  $CartItemsTable _cartItems;
  $CartItemsTable get cartItems => _cartItems ??= $CartItemsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [users, cartItems];
}
