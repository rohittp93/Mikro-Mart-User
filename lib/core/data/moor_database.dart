import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

@DataClassName('User')
class Users extends Table {
 TextColumn get uid => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  BoolColumn get phoneValidated => boolean()();


  @override
  Set<Column> get primaryKey => {uid};
}

class CartItems extends Table {
 TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  TextColumn get itemImage => text()();
  IntColumn get itemQuantity => integer()();

  @override
  Set<Column> get primaryKey => {itemId};
}


@UseMoor(tables: [Users, CartItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
      path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  Future<List<User>> getUsers() => select(users).get();
  //Stream<List<Purpose>> watchAllPurpose() => select(purposes).watch();
  Future insertUser(User user) => into(users).insert(user);
  Future updateUser(User user) => update(users).replace(user);
  Future deleteUser(User user) => delete(users).delete(user);


  Future<List<CartItem>> getCartItems() => select(cartItems).get();
  Stream<List<CartItem>> watchAllCartItems() => select(cartItems).watch();
  Future insertCartItem(CartItem cartItem) => into(cartItems).insert(cartItem);
  Future updateCartItem(CartItem cartItem) => update(cartItems).replace(cartItem);
  Future deleteCartItem(CartItem cartItem) => delete(cartItems).delete(cartItem);
}
